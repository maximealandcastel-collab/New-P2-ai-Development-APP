import 'package:flutter/material.dart';
    import 'package:get/get.dart';
    import 'package:pler_to_pler_app/core/di/dependency_injection.dart';
    import 'package:pler_to_pler_app/core/services/api_service.dart';
    import 'package:pler_to_pler_app/core/services/audio_focus_service.dart';
    import 'package:pler_to_pler_app/core/services/push_notification_service.dart';
    import 'app.dart';

    void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase.initializeApp() removed — GoogleService-Info.plist not yet added (Task #37)

    await DependencyInjection.init();

    // Configure the audio session once, here. It used to be configured from
    // ReelController, which is registered fenix, so every recreation
    // reconfigured the session and stacked another interruption listener.
    await AudioFocusService.instance.configure();

    // Push notifications — no-op stub until Firebase is configured
    PushNotificationService.instance
        .init(Get.find<ApiService>())
        .catchError((e) => print('[FCM] init error: $e'));

    runApp(const MyApp());
    }
    