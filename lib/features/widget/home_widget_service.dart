import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/geo.dart';

/// Pushes data to the Android/iOS home-screen widgets:
///  • latest zap (image + caption)
///  • distance to each group member
class HomeWidgetService {
  static const _androidZapProvider = 'ZapWidgetProvider';
  static const _androidDistanceProvider = 'DistanceWidgetProvider';

  static Future<void> updateLatestZap({
    required String senderName,
    String? caption,
    String? imageUrl,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('zap_sender', senderName);
      await HomeWidget.saveWidgetData<String>('zap_caption', caption ?? '');
      await HomeWidget.saveWidgetData<String>('zap_image', imageUrl ?? '');
      await HomeWidget.saveWidgetData<String>(
          'zap_time', DateTime.now().toIso8601String());
      await HomeWidget.updateWidget(
          androidName: _androidZapProvider, iOSName: 'ZapWidget');
    } catch (e) {
      debugPrint('home widget zap update failed: $e');
    }
  }

  /// Computes distance to each member from my last known location and writes
  /// a compact summary string for the lockscreen/home widget.
  static Future<void> updateDistances({
    required double myLat,
    required double myLng,
    required List<({String name, double lat, double lng})> members,
  }) async {
    try {
      final lines = <String>[];
      for (final m in members) {
        final km = haversineKm(myLat, myLng, m.lat, m.lng);
        lines.add('${m.name} — ${formatDistance(km)} away');
      }
      await HomeWidget.saveWidgetData<String>(
          'distances', lines.join('\n'));
      await HomeWidget.updateWidget(
          androidName: _androidDistanceProvider, iOSName: 'DistanceWidget');
    } catch (e) {
      debugPrint('home widget distance update failed: $e');
    }
  }

  /// Pushes the group pet's current state to the pet home-screen widget.
  static Future<void> updatePet({
    required String emoji,
    required String name,
    required String mood,
    required String stats,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('pet_emoji', emoji);
      await HomeWidget.saveWidgetData<String>('pet_name', name);
      await HomeWidget.saveWidgetData<String>('pet_mood', mood);
      await HomeWidget.saveWidgetData<String>('pet_stats', stats);
      await HomeWidget.updateWidget(
          androidName: 'PetWidgetProvider', iOSName: 'PetWidget');
    } catch (e) {
      debugPrint('pet widget update failed: $e');
    }
  }

  /// Fetches all group members' last locations and refreshes the widget.
  static Future<void> refreshDistances({
    required String groupId,
    required double myLat,
    required double myLng,
    required Map<String, String> roleNames, // userId -> roleName
    required String myUserId,
  }) async {
    try {
      final sb = Supabase.instance.client;
      final memberIds = roleNames.keys.where((id) => id != myUserId).toList();
      if (memberIds.isEmpty) return;
      final rows = await sb
          .from('user_locations')
          .select()
          .inFilter('user_id', memberIds);
      final members = <({String name, double lat, double lng})>[];
      for (final r in (rows as List)) {
        members.add((
          name: roleNames[r['user_id']] ?? 'member',
          lat: (r['lat'] as num).toDouble(),
          lng: (r['lng'] as num).toDouble(),
        ));
      }
      if (members.isNotEmpty) {
        await updateDistances(myLat: myLat, myLng: myLng, members: members);
      }
    } catch (e) {
      debugPrint('refreshDistances failed: $e');
    }
  }
}
