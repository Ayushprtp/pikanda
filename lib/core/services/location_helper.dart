import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationResult {
  final double lat;
  final double lng;
  final bool isLive;
  LocationResult(this.lat, this.lng, this.isLive);
}

class LocationHelper {
  static const _cacheLatKey = 'last_lat';
  static const _cacheLngKey = 'last_lng';

  /// Live GPS with [timeout]; falls back to last cached coordinates.
  static Future<LocationResult?> getPosition(
      {Duration timeout = const Duration(seconds: 20)}) async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _cached();
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            LocationSettings(accuracy: LocationAccuracy.high, timeLimit: timeout),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_cacheLatKey, pos.latitude);
      await prefs.setDouble(_cacheLngKey, pos.longitude);
      return LocationResult(pos.latitude, pos.longitude, true);
    } catch (_) {
      return _cached();
    }
  }

  static Future<LocationResult?> _cached() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_cacheLatKey);
    final lng = prefs.getDouble(_cacheLngKey);
    if (lat == null || lng == null) return null;
    return LocationResult(lat, lng, false);
  }

  /// Refreshes GPS and pushes to user_locations (powers the distance widget).
  static Future<LocationResult?> refreshAndUpload() async {
    final loc = await getPosition(timeout: const Duration(seconds: 12));
    if (loc == null || !loc.isLive) return loc;
    final sb = Supabase.instance.client;
    final uid = sb.auth.currentUser?.id;
    if (uid != null) {
      await sb.from('user_locations').upsert({
        'user_id': uid,
        'lat': loc.lat,
        'lng': loc.lng,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    }
    return loc;
  }
}
