import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One user-facing permission row: what it is, why we need it, how to get it.
class AppPermission {
  final String key;
  final String emoji;
  final String title;
  final String why;
  final List<Permission> permissions;
  final bool androidOnly;

  const AppPermission({
    required this.key,
    required this.emoji,
    required this.title,
    required this.why,
    required this.permissions,
    this.androidOnly = false,
  });

  bool get availableHere => !androidOnly || (!kIsWeb && Platform.isAndroid);

  Future<bool> get isGranted async {
    for (final p in permissions) {
      if (!await p.isGranted) return false;
    }
    return true;
  }

  Future<bool> get isPermanentlyDenied async {
    for (final p in permissions) {
      if (await p.isPermanentlyDenied) return true;
    }
    return false;
  }

  Future<bool> request() async {
    var all = true;
    for (final p in permissions) {
      final status = await p.request();
      if (!status.isGranted) all = false;
    }
    return all;
  }
}

/// Central catalogue of everything Pikanda may ask for, with honest reasons.
/// Every feature degrades gracefully when its permission is denied.
class PermissionService {
  static const all = [
    AppPermission(
      key: 'notifications',
      emoji: '🔔',
      title: 'Notifications',
      why: 'Zaps, pokes, pet alerts and daily messages from your group',
      permissions: [Permission.notification],
    ),
    AppPermission(
      key: 'location',
      emoji: '📍',
      title: 'Location',
      why: 'Live map, distance to your people, and SafeZap location sharing',
      permissions: [Permission.locationWhenInUse],
    ),
    AppPermission(
      key: 'location_bg',
      emoji: '🛰️',
      title: 'Background location',
      why: 'Lets the SafeZap 24h watchdog share your location even when the '
          'app is closed (optional — everything else works without it)',
      permissions: [Permission.locationAlways],
      androidOnly: true,
    ),
    AppPermission(
      key: 'camera',
      emoji: '📸',
      title: 'Camera',
      why: 'Take photos for Zaps and scan group invite QR codes',
      permissions: [Permission.camera],
    ),
    AppPermission(
      key: 'microphone',
      emoji: '🎙️',
      title: 'Microphone',
      why: 'Record 10-second voice notes on your Zaps',
      permissions: [Permission.microphone],
    ),
    AppPermission(
      key: 'sms',
      emoji: '✉️',
      title: 'SMS (SafeZap)',
      why: 'Send/receive encrypted SafeZap safety messages when there is no '
          'internet — Android only, used only if you enable SafeZap',
      permissions: [Permission.sms],
      androidOnly: true,
    ),
  ];

  static AppPermission byKey(String key) =>
      all.firstWhere((p) => p.key == key);

  /// First-run essentials: notifications + foreground location. Asked once,
  /// politely; everything else is requested in context when a feature needs it.
  static Future<void> requestEssentialsOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('essentials_requested') ?? false) return;
    await prefs.setBool('essentials_requested', true);
    try {
      await Permission.notification.request();
      await Permission.locationWhenInUse.request();
    } catch (e) {
      debugPrint('essential permission request failed: $e');
    }
  }

  static Future<bool> openSettings() => openAppSettings();
}
