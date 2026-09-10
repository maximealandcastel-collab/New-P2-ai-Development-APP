import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/staff_signup_screen.dart';

void main() {
  Future<void> tap(
    WidgetTester tester,
    Finder target, {
    double delta = 180,
  }) async {
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      target,
      delta,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) =>
      tap(tester, find.text('Continue ➜'));
  Future<void> boot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: StaffSignupScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'validates email, requires a role, and preserves details on Back',
    (tester) async {
      await boot(tester);
      await tester.enterText(
        find.byKey(const ValueKey('FULL NAME')),
        'Jordan Smith',
      );
      await tester.enterText(
        find.byKey(const ValueKey('WORK EMAIL')),
        'invalid',
      );
      await next(tester);
      expect(find.text('Enter a valid work email'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('WORK EMAIL')),
        'jordan@example.com',
      );
      await next(tester);
      await tester.scrollUntilVisible(find.text('Continue ➜'), 180);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Continue ➜'),
            )
            .onPressed,
        isNull,
      );
      await tap(tester, find.text('Back'), delta: -180);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('FULL NAME')))
            .controller!
            .text,
        'Jordan Smith',
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('WORK EMAIL')))
            .controller!
            .text,
        'jordan@example.com',
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final accessCode in ['', 'STAFF-1234']) {
    testWidgets(
      'staff request ${accessCode.isEmpty ? "without" : "with"} code retries without granting privileges',
      (tester) async {
        final original = EnterpriseService.instance;
        addTearDown(() => EnterpriseService.replaceForTesting(original));
        var calls = 0;
        final service = EnterpriseService(
          baseUrl: 'https://example.test',
          token: () => 'must-not-send',
          client: MockClient((request) async {
            calls++;
            expect(request.url.path, '/enterprise/staff-access-requests');
            expect(request.method, 'POST');
            expect(request.headers.containsKey('Authorization'), isFalse);
            final body = jsonDecode(request.body);
            expect(body['fullName'], 'Jordan Smith');
            expect(body['requestedRole'], 'gym_manager');
            expect(body['gymName'], 'HOTWORX');
            expect(body['tenantId'], isNull);
            expect(body['accessCode'], accessCode.isEmpty ? null : accessCode);
            if (calls == 1) return http.Response('{}', 503);
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {'requestId': 'staff-1', 'status': 'pending_review'},
              }),
              201,
            );
          }),
        );
        EnterpriseService.replaceForTesting(service);
        await boot(tester);
        await tester.enterText(
          find.byKey(const ValueKey('FULL NAME')),
          'Jordan Smith',
        );
        await tester.enterText(
          find.byKey(const ValueKey('WORK EMAIL')),
          'jordan@example.com',
        );
        await next(tester);
        await tap(tester, find.text('Gym Manager'));
        await next(tester);
        await tap(tester, find.text('HOTWORX'));
        await next(tester);
        expect(find.text('Access\nPending'), findsOneWidget);
        if (accessCode.isNotEmpty) {
          await tester.ensureVisible(
            find.byKey(const ValueKey('ENTER ACCESS CODE (OPTIONAL)')),
          );
          await tester.enterText(
            find.byKey(const ValueKey('ENTER ACCESS CODE (OPTIONAL)')),
            accessCode,
          );
        }
        await tap(tester, find.text('Request Access ➜'));
        expect(find.textContaining('We couldn’t send'), findsOneWidget);
        expect(service.active.value, isNull);
        await tap(tester, find.text('Request Access ➜'));
        await tester.scrollUntilVisible(find.text('Request\nReceived'), -180);
        expect(find.text('Reference: staff-1'), findsOneWidget);
        expect(service.active.value, isNull);
        expect(calls, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test('staff receipt rejects active access and malformed success', () async {
    for (final data in [
      {'requestId': '123', 'status': 'active'},
      {'requestId': '', 'status': 'pending_review'},
    ]) {
      final service = EnterpriseService(
        baseUrl: 'https://example.test',
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode({'success': true, 'data': data}), 200),
        ),
      );
      await expectLater(
        service.requestStaffAccess({}),
        throwsA(isA<EnterpriseException>()),
      );
      expect(service.active.value, isNull);
    }
  });
}
