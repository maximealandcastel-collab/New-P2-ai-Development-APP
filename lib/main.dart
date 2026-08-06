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

    // Firebase init — wrapped so a config mismatch or network timeout on first
    // launch never prevents the app from opening. Push notifications simply
    // won't work if this fails, but the app will still run.
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('[Firebase] init error: $e');
    }

    await DependencyInjection.init();

    // Push notifications — already non-blocking via catchError.
    PushNotificationService.instance
        .init(Get.find<ApiService>())
        .catchError((e) => debugPrint('[FCM] init error: $e'));

    runApp(const MyApp());
    }
    