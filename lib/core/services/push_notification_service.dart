import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Response;
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';

class PushNotificationService with WidgetsBindingObserver {
  PushNotificationService._();
  static final instance = PushNotificationService._();
  ApiService? _api;
  Future<void>? _initializing;
  String? _registeredToken;
  bool _ready = false;
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
      _ready = true;
      WidgetsBinding.instance.addObserver(this);
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        unawaited(syncToken(token: token));
      });
      FirebaseMessaging.onMessageOpenedApp.listen((_) => _openNotification());
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _pendingTap = true;
      await syncToken();
    } catch (error) {
      debugPrint('Push initialization unavailable: ${error.runtimeType}');
      _initializing = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(syncToken());
  }

  Future<void> syncToken({String? token}) async {
    final access = CacheService().get<String>(AppConstants.accessToken);
    if (!_ready || access == null || access.isEmpty) return;
    final generation = _generation;
    try {
      final permission = await FirebaseMessaging.instance.requestPermission();
      if (permission.authorizationStatus == AuthorizationStatus.denied) return;
      if (Platform.isIOS && await FirebaseMessaging.instance.getAPNSToken() == null) return;
      final current = token ?? await FirebaseMessaging.instance.getToken();
      if (current == null || generation != _generation ||
          access != CacheService().get<String>(AppConstants.accessToken)) return;
      await _api!.patch(ApiConstants.updateFcmToken,
        data: {'fcmToken': current}, options: Options(headers: {
          ApiConstants.requiresAuthHeader: false, 'Authorization': 'Bearer $access',
        }));
      if (generation == _generation) _registeredToken = current;
      if (_pendingTap) _openNotification();
    } catch (error) {
      debugPrint('Push registration will retry on resume: ${error.runtimeType}');
    }
  }

  Future<void> signOut() async {
    _generation++;
    _pendingTap = false;
    if (!_ready) return;
    try {
      final token = _registeredToken ?? await FirebaseMessaging.instance.getToken();
      if (token != null) await _api?.patch(ApiConstants.updateFcmToken,
        data: {'fcmToken': null, 'previousFcmToken': token});
    } catch (_) {
      // Deleting the device token also invalidates delivery if server cleanup fails.
    } finally {
      _registeredToken = null;
      try { await FirebaseMessaging.instance.deleteToken(); } catch (_) {}
    }
  }

  void _openNotification() {
    if (CacheService().get<String>(AppConstants.accessToken)?.isNotEmpty != true || Get.context == null) {
      _pendingTap = true;
      return;
    }
    _pendingTap = false;
    // The authenticated inbox fetches recipient-owned records. Never execute an
    // arbitrary route or trust an account/tenant ID supplied in a push payload.
    Get.toNamed(AppRoute.notificationsScreen);
  }
}
