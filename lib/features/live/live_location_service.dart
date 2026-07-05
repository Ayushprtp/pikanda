import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Continuously uploads the user's location while "live sharing" is on, so
/// group members see a fresh position + real-time distance. A member counts as
/// "live" when their row was updated in the last 2 minutes (see UserLocation).
///
/// Also drives an ongoing (persistent) notification showing distance to the
/// nearest member, and the home-screen distance widget.
class LiveLocationService {
  LiveLocationService._();
  static final instance = LiveLocationService._();

  static const _kSharing = 'live_sharing_enabled';
  static const _ongoingChannel = 'pikanda_live_location';
  static const _ongoingId = 42;

  StreamSubscription<Position>? _sub;
  final _local = FlutterLocalNotificationsPlugin();

  Future<bool> isSharing() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSharing) ?? false;
  }

  Future<void> setSharing(bool on) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSharing, on);
    if (on) {
      await start();
    } else {
      await stop();
    }
  }

  Future<bool> _ensurePermission() async {
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  /// Begins streaming position updates (every ~10 m or 8 s) to Supabase.
  Future<void> start() async {
    if (!await _ensurePermission()) return;
    await _sub?.cancel();
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(_upload);
    // Push one immediately so the partner sees us right away.
    try {
      final pos = await Geolocator.getCurrentPosition();
      await _upload(pos);
    } catch (_) {}
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _local.cancel(_ongoingId);
  }

  Future<void> _upload(Position pos) async {
    try {
      final sb = Supabase.instance.client;
      final uid = sb.auth.currentUser?.id;
      if (uid == null) return;
      // Try the richer RPC first (migration 0011); fall back to base upsert.
      try {
        await sb.rpc('update_my_location', params: {
          'p_lat': pos.latitude,
          'p_lng': pos.longitude,
          'p_sharing': true,
          'p_share_minutes': 120,
          'p_accuracy': pos.accuracy,
          'p_speed': pos.speed,
        });
      } catch (_) {
        await sb.from('user_locations').upsert({
          'user_id': uid,
          'lat': pos.latitude,
          'lng': pos.longitude,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('live location upload failed: $e');
    }
  }

  /// Shows/updates the ongoing "distance to nearest" notification.
  Future<void> updateOngoingNotification({
    required String nearestName,
    required String distanceText,
  }) async {
    try {
      await _local.show(
        _ongoingId,
        '📍 $nearestName — $distanceText away',
        'Live location sharing is on',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _ongoingChannel,
            'Live Location',
            channelDescription: 'Ongoing distance to your people',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            onlyAlertOnce: true,
            showWhen: false,
            category: AndroidNotificationCategory.service,
          ),
          iOS: const DarwinNotificationDetails(presentBadge: false),
        ),
      );
    } catch (e) {
      debugPrint('ongoing notification failed: $e');
    }
  }
}
