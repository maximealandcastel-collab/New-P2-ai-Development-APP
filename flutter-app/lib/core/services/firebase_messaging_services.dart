import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.notification?.title}');
}

class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Call once from main() after Firebase.initializeApp().
  Future<void> initialize() async {
    // Register background handler.
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

    // Request permission (iOS / macOS / web).
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // Foreground presentation options for iOS.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen while app is in foreground.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App opened from a notification tap (background → foreground).
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Opened from notification: ${message.data}');
      _handleNotificationTap(message);
    });

    // App launched from a terminated state via notification.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] Launched via notification: ${initial.data}');
      _handleNotificationTap(initial);
    }
  }

  /// Returns the FCM device token, waiting for APNs first on iOS.
  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        // Wait up to 5 s for the APNs token before requesting FCM token.
        String? apns;
        for (int i = 0; i < 10 && apns == null; i++) {
          apns = await _messaging.getAPNSToken();
          if (apns == null) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
        if (apns == null) {
          debugPrint('[FCM] APNs token unavailable — skipping FCM token fetch');
          return null;
        }
      }

      final token = await _messaging.getToken();
      debugPrint('[FCM] Token: $token');
      return token;
    } catch (e) {
      debugPrint('[FCM] getToken error: $e');
      return null;
    }
  }

  /// Subscribe to a named topic (e.g. "all_users", "trainer_<id>").
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('[FCM] Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('[FCM] Unsubscribed from topic: $topic');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
        '[FCM] Foreground: ${message.notification?.title} — ${message.notification?.body}');
    // TODO: show an in-app banner or update relevant UI state here.
  }

  void _handleNotificationTap(RemoteMessage message) {
    // TODO: navigate based on message.data payload (e.g. {"screen": "chat", "id": "123"}).
  }
}
