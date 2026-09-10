import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gym_application_screen.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gym_onboarding_screen.dart';

void main() {
  test(
    'application intake is public and accepts only a pending review receipt',
    () async {
      final service = EnterpriseService(
        baseUrl: 'https://example.test',
        token: () => 'private-token',
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/enterprise/gym-applications');
          expect(request.headers.containsKey('Authorization'), isFalse);
          expect(jsonDecode(request.body)['gymName'], 'Test Gym');
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'applicationId': 'receipt-1',
                'status': 'pending_review',
              },
            }),
            201,
          );
        }),
      );
      expect(
        await service.submitGymApplication({'gymName': 'Test Gym'}),
        'receipt-1',
      );
      expect(service.active.value, isNull);
    },
  );

  test('invalid receipt cannot activate a gym or claim submission', () async {
    for (final data in [
      {'applicationId': '', 'status': 'pending_review'},
      {'applicationId': '123', 'status': 'active'},
    ]) {
      final service = EnterpriseService(
        baseUrl: 'https://example.test',
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode({'success': true, 'data': data}), 200),
        ),
      );
      await expectLater(
        service.submitGymApplication({}),
        throwsA(isA<EnterpriseException>()),
      );
      expect(service.active.value, isNull);
    }
  });

  testWidgets('welcome requires a path and Staff opens signup', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: GymOnboardingScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Continue ➜'), 120);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue ➜'))
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(find.text('Staff / Admin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Staff / Admin'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue ➜'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue ➜'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.text('Staff\nSign Up'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Gym Partner entry proceeds to licensing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GymOnboardingScreen(gymEntry: true)),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Continue ➜'), 120);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue ➜'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Claim Your Gym opens licensing without selecting a path', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GymOnboardingScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('CLAIM ➜'), 120);
    await tester.pumpAndSettle();
    await tester.tap(find.text('CLAIM ➜'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
