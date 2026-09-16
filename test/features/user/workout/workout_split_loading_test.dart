import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';
import 'package:pler_to_pler_app/features/user/workout_find/presentation/workout_find_screen.dart';

void main() {
  testWidgets(
    'stalled split request exits loading and exposes a reference',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final original = ApiClient.client;
      final pending = Completer<http.Response>();
      var splitRequested = false;
      http.Request? splitRequest;
      ApiClient.client = MockClient((request) async {
        if (request.url.path.endsWith('/splits')) {
          splitRequested = true;
          splitRequest = request;
          return pending.future;
        }
        return http.Response(
          '{"success":true,"data":{"_id":"123456789012345678901234"}}',
          201,
          request: request,
        );
      });
      addTearDown(() {
        ApiClient.client = original;
        Get.reset();
      });
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) =>
              const GetMaterialApp(home: WorkoutFinderFlow()),
        ),
      );
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('Skip'));
        await tester.pump();
      }
      for (var i = 0; i < 10 && !splitRequested; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(splitRequested, isTrue);
      await tester.pump(const Duration(seconds: 46));
      expect(find.textContaining('did not respond in time'), findsOneWidget);
      expect(find.textContaining('Reference: splits-'), findsOneWidget);
      pending.complete(
        http.Response(
          '{"success":false,"message":"late response"}',
          503,
          request: splitRequest,
        ),
      );
      await tester.pump();
      expect(find.textContaining('did not respond in time'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'successful split request opens the selection screen',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final original = ApiClient.client;
      ApiClient.client = MockClient(
        (request) async => http.Response(
          jsonEncode({
            'success': true,
            'data': request.url.path.endsWith('/splits')
                ? {
                    'splitOptions': [
                      for (var i = 1; i <= 3; i++)
                        {
                          'id': 'split_$i',
                          'name': 'Plan $i',
                          'weeklySchedule': [
                            'Full Body A',
                            'Full Body B',
                            'Full Body C',
                          ],
                          'daysPerWeek': 3,
                          'estimatedSessionMinutes': 30,
                        },
                    ],
                  }
                : {'_id': '123456789012345678901234'},
          }),
          request.url.path.endsWith('/splits') ? 200 : 201,
          request: request,
        ),
      );
      addTearDown(() {
        ApiClient.client = original;
        Get.reset();
      });
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) =>
              const GetMaterialApp(home: WorkoutFinderFlow()),
        ),
      );
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('Skip'));
        await tester.pump();
      }
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(find.text('Choose Your Workout Split'), findsOneWidget);
      expect(find.text('Plan 1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
}