import 'dart:async';
import 'dart:io' show Platform;

import 'package:another_telephony/telephony.dart' hide NetworkType;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/config.dart';
import '../../core/services/location_helper.dart';
import '../../core/utils/aes_helper.dart';

/// SafeZap: personal-safety location sharing within your own group.
///
/// Three triggers, all sending the *user's own* location to their group:
///  A — 24h without opening the app (background watchdog)
///  S — a member texts the group's secret code to this phone
///  W — the user triple-taps the app logo (silent panic button)
///
/// Payload format (sent over SMS, Android only):
///   PKD:v1:<aes_hex_iv.aes_hex_cipher>:<A|S|W>
/// Plaintext before encryption: "LAT,LNG,MILLIS_TIMESTAMP"
/// A parallel row is written to location_events when the network is up.
class SafeZapService {
  static const _kGroupId = 'sz_group_id';
  static const _kAesSalt = 'sz_aes_salt';
  static const _kPhones = 'sz_phone_numbers';
  static const _kCodeHash = 'sz_code_hash';
  static const _kEnabled = 'sz_enabled';
  static const watchdogTask = 'pikanda_safezap_24h';

  final Telephony _telephony = Telephony.instance;

  bool get smsSupported => !kIsWeb && Platform.isAndroid;

  /// Caches everything the background isolate needs. Call whenever the
  /// active group changes or membership loads.
  Future<void> cacheGroupData({
    required String groupId,
    required String aesSalt,
    required List<String> memberPhones,
    String? safeCodeHash,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGroupId, groupId);
    await prefs.setString(_kAesSalt, aesSalt);
    await prefs.setStringList(_kPhones, memberPhones);
    if (safeCodeHash != null) await prefs.setString(_kCodeHash, safeCodeHash);
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabled) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, enabled);
    if (!smsSupported) return;
    if (enabled) {
      await _telephony.requestPhoneAndSmsPermissions;
      startSmsListener();
      await resetWatchdog();
    } else {
      await Workmanager().cancelByUniqueName(watchdogTask);
    }
  }

  /// Re-arms the 24-hour watchdog. Call on every app open.
  Future<void> resetWatchdog() async {
    if (!smsSupported || !await isEnabled()) return;
    await Workmanager().cancelByUniqueName(watchdogTask);
    await Workmanager().registerOneOffTask(
      watchdogTask,
      watchdogTask,
      initialDelay: const Duration(hours: 24),
      constraints: Constraints(networkType: NetworkType.notRequired),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Trigger 3 — safe word (triple-tap on logo). Completely silent.
  Future<void> triggerSafeWord() => fireTrigger('safe_word');

  /// Shared trigger pipeline used by all three entry points.
  Future<void> fireTrigger(String triggerType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupId = prefs.getString(_kGroupId);
      final salt = prefs.getString(_kAesSalt);
      if (groupId == null || salt == null) return;

      final loc = await LocationHelper.getPosition();
      if (loc == null) return;

      final aes = AesHelper.forGroup(groupId, salt);
      final plain =
          '${loc.lat},${loc.lng},${DateTime.now().millisecondsSinceEpoch}';
      final encrypted = aes.encryptText(plain);
      final flag = switch (triggerType) {
        'safe_word' => 'W',
        'secret_code' => 'S',
        _ => 'A',
      };

      // 1. SMS to all group members (works with no internet) — Android only.
      if (smsSupported) {
        final phones = prefs.getStringList(_kPhones) ?? [];
        final payload = '${AppConfig.safezapPrefix}$encrypted:$flag';
        for (final phone in phones) {
          try {
            await _telephony.sendSms(to: phone, message: payload);
          } catch (e) {
            debugPrint('SafeZap SMS to $phone failed: $e');
          }
        }
      }

      // 2. Backend row (works when online) → map screen + push notification.
      try {
        final sb = Supabase.instance.client;
        final uid = sb.auth.currentUser?.id;
        if (uid != null) {
          await sb.from('location_events').insert({
            'group_id': groupId,
            'sender_id': uid,
            'trigger_type': triggerType,
            'encrypted_coords': encrypted,
            'is_live_gps': loc.isLive,
          });
        }
      } catch (e) {
        debugPrint('SafeZap backend log failed (probably offline): $e');
      }
    } catch (e) {
      debugPrint('SafeZap trigger failed: $e');
    }
  }

  /// Listens for incoming SMS: secret-code triggers and PKD payloads.
  void startSmsListener() {
    if (!smsSupported) return;
    _telephony.listenIncomingSms(
      onNewMessage: handleIncomingSms,
      onBackgroundMessage: safezapBackgroundSmsHandler,
      listenInBackground: true,
    );
  }

  static Future<void> handleIncomingSms(SmsMessage message) =>
      processIncomingSmsBody(message.body ?? '');

  /// Decides what an incoming SMS means. Static so the background isolate
  /// can reuse it.
  static Future<void> processIncomingSmsBody(String body) async {
    final prefs = await SharedPreferences.getInstance();

    if (body.startsWith(AppConfig.safezapPrefix)) {
      // Someone in the group sent their location. Store it for the map.
      final groupId = prefs.getString(_kGroupId);
      final payload = body.substring(AppConfig.safezapPrefix.length);
      final lastColon = payload.lastIndexOf(':');
      if (lastColon < 0 || groupId == null) return;
      final encrypted = payload.substring(0, lastColon);
      final flag = payload.substring(lastColon + 1);
      final received = prefs.getStringList('sz_received') ?? [];
      received.add('$groupId|$flag|$encrypted|${DateTime.now().millisecondsSinceEpoch}');
      if (received.length > 50) received.removeRange(0, received.length - 50);
      await prefs.setStringList('sz_received', received);
      return;
    }

    // Secret code check: an SMS whose whole body matches the group code.
    final codeHash = prefs.getString(_kCodeHash);
    if (codeHash != null && AesHelper.hashSafeCode(body) == codeHash) {
      await SafeZapService().fireTrigger('secret_code');
    }
  }

  /// SMS-received payloads cached on this device (offline path).
  Future<List<(String flag, String encrypted, DateTime at)>>
      receivedSmsEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final groupId = prefs.getString(_kGroupId);
    final rows = prefs.getStringList('sz_received') ?? [];
    final out = <(String, String, DateTime)>[];
    for (final r in rows) {
      final parts = r.split('|');
      if (parts.length != 4 || parts[0] != groupId) continue;
      out.add((
        parts[1],
        parts[2],
        DateTime.fromMillisecondsSinceEpoch(int.tryParse(parts[3]) ?? 0)
      ));
    }
    return out;
  }
}

final safeZapServiceProvider = Provider<SafeZapService>((ref) => SafeZapService());

/// Background SMS handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> safezapBackgroundSmsHandler(SmsMessage message) async {
  await SafeZapService.processIncomingSmsBody(message.body ?? '');
}

/// Workmanager entry point for the 24h watchdog.
@pragma('vm:entry-point')
void safezapWorkmanagerDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == SafeZapService.watchdogTask) {
      await SafeZapService().fireTrigger('auto_24hr');
    }
    return true;
  });
}
