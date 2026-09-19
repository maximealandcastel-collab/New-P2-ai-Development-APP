import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Response;
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/notification/presentation/controllers/notification_controller.dart';

/// Owns the complete device side of P2P push notifications:
///
/// * Firebase/APNs permission and token registration
/// * token refresh and account-safe token removal on logout
/// * visible foreground notifications on both iOS and Android
/// * notification tap-through to the authenticated inbox
/// * inbox badge/list refresh while the app is already open
class PushNotificationService with WidgetsBindingObserver {
  PushNotificationService._();

  static final instance = PushNotificationService._();

  static const _channel = AndroidNotificationChannel(
    'p2p_high_importance',
    'P2P Updates',
    description: 'Workout, trainer, gym, progress, and account updates.',
    importance: Importance.high,
    playSound: true,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  ApiService? _api;
  Future<void>? _initializing;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _tapSubscription;
  String? _registeredToken;
  bool _ready = false;
  bool _localReady = false;
  bool _pendingTap = false;
  int _generation = 0;

  Future<void> init(ApiService api) {
    _api = api;
    return _initializing ??= _initialize();
  }

  Future<void> _initialize() async {
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) return;

    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      await _initializeLocalNotifications();

      _ready = true;
      WidgetsBinding.instance.addObserver(this);

      await _tokenSubscription?.cancel();
      _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
        (token) => unawaited(syncToken(token: token)),
      );

      await _messageSubscription?.cancel();
      _messageSubscription = FirebaseMessaging.onMessage.listen(
        _showForegroundNotification,
      );

      await _tapSubscription?.cancel();
      _tapSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        (_) => _openNotification(),
      );

      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) _pendingTap = true;

      final localLaunch =
          await _localNotifications.getNotificationAppLaunchDetails();
      if (localLaunch?.didNotificationLaunchApp == true) _pendingTap = true;

      // A restored authenticated session can register immediately. On a fresh
      // login LoginController calls syncToken as soon as the token is cached.
      await syncToken();
    } catch (error, stack) {
      debugPrint('Push initialization unavailable: ${error.runtimeType}');
      if (kDebugMode) debugPrintStack(stackTrace: stack);
      _initializing = null;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (_) => _openNotification(),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Firebase notifications are rendered locally while foregrounded, which
    // prevents duplicate iOS banners while preserving sound and badge support.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
    _localReady = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(syncToken());
  }

  Future<NotificationSettings?> _authorizedSettings() async {
    var settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }
    if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
    return settings;
  }

  Future<void> syncToken({String? token}) async {
    final access = CacheService().get<String>(AppConstants.accessToken);
    if (!_ready || access == null || access.isEmpty) return;

    final generation = _generation;
    try {
      if (await _authorizedSettings() == null) return;

      if (Platform.isIOS) {
        var apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          await Future<void>.delayed(const Duration(milliseconds: 750));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        }
        if (apnsToken == null) return;
      }

      final current = token ?? await FirebaseMessaging.instance.getToken();
      if (current == null || current.isEmpty) return;
      if (generation != _generation ||
          access != CacheService().get<String>(AppConstants.accessToken)) {
        return;
      }

      if (_registeredToken != current) {
        await _api!.patch(
          ApiConstants.updateFcmToken,
          data: {'fcmToken': current},
          options: Options(
            headers: {
              ApiConstants.requiresAuthHeader: false,
              'Authorization': 'Bearer $access',
            },
          ),
        );
        if (generation == _generation) _registeredToken = current;
      }

      if (_pendingTap) _openNotification();
    } catch (error) {
      debugPrint(
        'Push registration will retry on resume: ${error.runtimeType}',
      );
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!_localReady) return;

    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'P2P Fit Tech AI';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';
    if (body.trim().isEmpty) return;

    await _localNotifications.show(
      message.messageId?.hashCode ??
          DateTime.now().microsecondsSinceEpoch.remainder(2147483647),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'p2p_high_importance',
          'P2P Updates',
          channelDescription:
              'Workout, trainer, gym, progress, and account updates.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );

    if (Get.isRegistered<NotificationController>()) {
      unawaited(NotificationController.to.refresh());
    }
  }

  Future<void> signOut() async {
    _generation++;
    _pendingTap = false;
    if (!_ready) return;

    try {
      final token =
          _registeredToken ?? await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _api?.patch(
          ApiConstants.updateFcmToken,
          data: {'fcmToken': null, 'previousFcmToken': token},
        );
      }
    } catch (_) {
      // Deleting the device token also prevents further delivery if backend
      // cleanup is temporarily unavailable.
    } finally {
      _registeredToken = null;
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}
      await _localNotifications.cancelAll();
    }
  }

  void _openNotification() {
    final access = CacheService().get<String>(AppConstants.accessToken);
    if (access?.isNotEmpty != true || Get.context == null) {
      _pendingTap = true;
      return;
    }

    _pendingTap = false;
    // The authenticated inbox fetches recipient-owned records. Never execute an
    // arbitrary route or trust an account/tenant ID supplied in a push payload.
    if (Get.currentRoute != AppRoute.notificationsScreen) {
      Get.toNamed(AppRoute.notificationsScreen);
    }
  }
}
