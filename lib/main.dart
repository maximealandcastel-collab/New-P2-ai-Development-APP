import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/di/dependency_injection.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/audio_focus_service.dart';
import 'package:pler_to_pler_app/core/services/push_notification_service.dart';

import 'app.dart';

const _buildNumber = String.fromEnvironment('BUILD_NUMBER', defaultValue: 'dev');

void _recordUnhandled(String source, Object error, StackTrace stack) {
  debugPrint('[UNHANDLED][$source][build=$_buildNumber] $error');
  debugPrintStack(label: '[UNHANDLED][$source]', stackTrace: stack);
}

Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _recordUnhandled(
        'flutter',
        details.exception,
        details.stack ?? StackTrace.current,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _recordUnhandled('platform', error, stack);
      // Returning false preserves the engine's normal fatal-error behavior.
      return false;
    };

    await DependencyInjection.init();
    await AudioFocusService.instance.configure();

    unawaited(
      PushNotificationService.instance
          .init(Get.find<ApiService>())
          .catchError((Object error, StackTrace stack) {
        _recordUnhandled('push-init', error, stack);
      }),
    );

    runApp(const MyApp());
  }, (error, stack) {
    _recordUnhandled('zone', error, stack);
  });
}
