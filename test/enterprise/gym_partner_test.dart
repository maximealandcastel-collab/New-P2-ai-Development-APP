import 'directory_fixture.dart';
import 'dart:convert';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gym_application_screen.dart';

class FakeLauncher extends UrlLauncherPlatform {
  int calls = 0;
  @override
  get linkDelegate => null;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async =>
      ++calls > 1;
}

void main() {
  late EnterpriseService directoryOriginal;
  setUp(() {
    directoryOriginal = EnterpriseService.instance;
    EnterpriseService.replaceForTesting(directoryFixtureService());
  });
  tearDown(() {
    EnterpriseService.replaceForTesting(directoryOriginal);
  });
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

  Future<void> fill(WidgetTester tester, String key, String value) async {
    final target = find.byKey(ValueKey(key));
    await tester.scrollUntilVisible(
      target,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(target);
    await tester.enterText(target, value);
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) =>
      tap(tester, find.text('Continue ➜'));
  Future<void> boot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: GymApplicationScreen()));
    await tester.pumpAndSettle();
  }

  for (final tier in ['starter', 'pro']) {
    testWidgets(
      '$tier partnership preserves brand and retries pending submission',
      (tester) async {
        final original = EnterpriseService.instance;
        addTearDown(() => EnterpriseService.replaceForTesting(original));
        final originalLauncher = UrlLauncherPlatform.instance;
        UrlLauncherPlatform.instance = FakeLauncher();
        addTearDown(() => UrlLauncherPlatform.instance = originalLauncher);
        var calls = 0;
        final service = EnterpriseService(
          baseUrl: 'https://example.test',
          client: MockClient((request) async {
            if (request.method == 'GET') return directoryFixtureResponse();
            calls++;
            final body = jsonDecode(request.body);
            expect(body['gymName'], 'Iron City Fitness');
            expect(body['gymType'], 'CrossFit Affiliate');
            expect(body['shortCode'], 'ICF');
            expect(body['primaryColor'], '#E53E3E');
            expect(body['secondaryColor'], '#112233');
            expect(body['logoUrl'], 'https://example.com/gym.png');
            expect(body['locationCount'], 1);
            expect(body['activeMembers'], 500);
            expect(body['tier'], tier);
            expect(body['authorizedRepresentative'], isTrue);
            expect(body.containsKey('tenantId'), isFalse);
            expect(body.containsKey('paymentStatus'), isFalse);
            if (calls == 1) return http.Response('{}', 503);
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {
                  'applicationId': 'partner-42',
                  'status': 'pending_review',
                },
              }),
              201,
            );
          }),
        );
        EnterpriseService.replaceForTesting(service);
        await boot(tester);
        await fill(tester, 'gymName', 'Iron City Fitness');
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();
        await tap(tester, find.text('CrossFit Affiliate'));
        await next(tester);
        expect(find.text('Step 2 of 5'), findsOneWidget);
        await tap(tester, find.bySemanticsLabel('Brand color #E53E3E'));
        await fill(tester, 'Secondary color hex', '#112233');
        await fill(tester, 'logoUrl', 'https://example.com/gym.png');
        await next(tester);
        await fill(tester, 'city', 'Denver');
        await fill(tester, 'state', 'CO');
        await next(tester);
        await tap(
          tester,
          find.text(
            tier == 'starter' ? 'Enterprise Starter' : 'Enterprise Pro',
          ),
        );
        await fill(tester, 'representativeName', 'Jordan Smith');
        await fill(tester, 'workEmail', 'jordan@example.com');
        await fill(tester, 'phone', '+13035551234');
        await tester.scrollUntilVisible(
          find.text('Continue to Clover Checkout ➜'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(
                  FilledButton,
                  'Continue to Clover Checkout ➜',
                ),
              )
              .onPressed,
          isNull,
        );
        await tap(tester, find.byType(CheckboxListTile));
        await tap(tester, find.text('Continue to Clover Checkout ➜'));
        expect(find.textContaining('We couldn’t submit'), findsOneWidget);
        expect(find.text('PARTNERSHIP SUBMITTED'), findsNothing);
        await tap(tester, find.text('Continue to Clover Checkout ➜'));
        expect(
          find.textContaining('Your application was submitted.'),
          findsOneWidget,
        );
        expect(calls, 2);
        await tap(tester, find.text('Continue to Clover Checkout ➜'));
        expect(find.text('Step 5 of 5'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Pending review'),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('partner-42'), findsOneWidget);
        expect(find.textContaining("You're Live"), findsNothing);
        expect(service.active.value, isNull);
        expect(calls, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('existing gym claim and brand settings survive Back', (
    tester,
  ) async {
    await boot(tester);
    await tap(tester, find.text('KMF Fitness Club'));
    await tap(tester, find.text('Full-Service Gym'));
    await next(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('shortCode')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('shortCode')))
          .controller!
          .text,
      'KFC',
    );
    await fill(tester, 'shortCode', 'KMF');
    await fill(tester, 'Primary color hex', '#0056AB');
    await next(tester);
    await tap(tester, find.text('Back'));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('shortCode')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('shortCode')))
          .controller!
          .text,
      'KMF',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('Primary color hex')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('Primary color hex')),
          )
          .controller!
          .text,
      '#0056AB',
    );
    expect(tester.takeException(), isNull);
  });
}
