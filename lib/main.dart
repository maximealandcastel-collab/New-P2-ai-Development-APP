import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/di/dependency_injection.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/push_notification_service.dart';
import 'package:pler_to_pler_app/firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase must be initialised before DI so the background message handler
  // is registered before any other async work runs.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await DependencyInjection.init();

  // Initialise push notifications — non-blocking so a permission denial or
  // missing APNs token never prevents the app from launching.
  PushNotificationService.instance
      .init(Get.find<ApiService>())
      .catchError((e) => debugPrint('[FCM] init error: $e'));

  runApp(const MyApp());
}
