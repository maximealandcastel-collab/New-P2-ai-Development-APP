import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'p2p_fittech_channel';
  static const _channelName = 'P2P FitTech AI';
  static const _channelDesc = 'Workout updates and trainer messages';

  Future<void> init(ApiService apiService) async {
    // Register background handler before anything else
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (required on iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] User denied push notification permission');
      return;
    }

    // iOS: hand APNs token to Firebase automatically
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      // Wait briefly for APNs token to propagate before getting FCM token
      await Future.delayed(const Duration(seconds: 2));
    }

    // Set up local notification channel (required for Android foreground display;
    // harmless on iOS)
    await _initLocalNotifications();

    // Get FCM token and upload to backend
    await _registerToken(apiService);

    // Token refresh listener
    _messaging.onTokenRefresh.listen((token) {
      debugPrint('[FCM] Token refreshed');
      _uploadToken(token, apiService);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // App opened from notification (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Opened via notification: ${message.data}');
      _handleNotificationTap(message);
    });

    // App launched from terminated state via notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] Launched from terminated via notification');
      _handleNotificationTap(initial);
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _registerToken(ApiService apiService) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[FCM] Token obtained (${token.length} chars)');
        await _uploadToken(token, apiService);
      } else {
        debugPrint('[FCM] Token is null — APNs not ready yet');
      }
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
    }
  }

  Future<void> _uploadToken(String token, ApiService apiService) async {
    try {
      await apiService.patch(
        ApiConstants.updateFcmToken,
        data: {'fcmToken': token},
      );
      debugPrint('[FCM] Token uploaded to backend');
    } catch (e) {
      // Non-fatal — token will be retried on next launch
      debugPrint('[FCM] Failed to upload token: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Add deep-link routing here when needed
    // e.g. route to notifications screen, chat, workout etc.
    debugPrint('[FCM] Notification tap data: ${message.data}');
  }
}
