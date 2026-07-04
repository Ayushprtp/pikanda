import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../firebase_options.dart';

/// FCM + local notification plumbing. Fully guarded: the app works without
/// Firebase config (notifications silently disabled).
class NotificationService {
  static final _local = FlutterLocalNotificationsPlugin();
  static bool _firebaseReady = false;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      _firebaseReady = true;
    } catch (e) {
      debugPrint('Firebase init failed (notifications disabled): $e');
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit));

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    // Show foreground pushes as local notifications.
    FirebaseMessaging.onMessage.listen((RemoteMessage m) {
      final n = m.notification;
      if (n == null) return;
      _local.show(
        n.hashCode,
        n.title,
        n.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pikanda_main',
            'Pikanda',
            channelDescription: 'Zaps, pokes, pets and everything else',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }

  /// Uploads this device's FCM token to the user profile (server pushes).
  static Future<void> syncToken() async {
    if (!_firebaseReady) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final sb = Supabase.instance.client;
      final uid = sb.auth.currentUser?.id;
      if (token != null && uid != null) {
        await sb.from('users').update({'fcm_token': token}).eq('id', uid);
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
        final u = sb.auth.currentUser?.id;
        if (u != null) await sb.from('users').update({'fcm_token': t}).eq('id', u);
      });
    } catch (e) {
      debugPrint('FCM token sync failed: $e');
    }
  }
}
