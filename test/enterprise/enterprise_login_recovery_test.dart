import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/login_result_model.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_access_recovery_screen.dart';

class FakeAuth extends Fake implements AuthService {
  int logins = 0;
  @override
  Future<LoginResultModel> login({
    required String email,
    required String password,
  }) async {
    logins++;
    return LoginResultModel(
      token: 'test-session',
      onboardingCompleted: true,
      isSubscribed: false,
    );
  }

  @override
  String? getRole() => 'user';
}

class FakeProfile extends Fake implements ProfileService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory storage;
  setUpAll(() async {
    storage = await Directory.systemTemp.createTemp('login-test-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => storage.path);
    await CacheService().init();
  });
  tearDownAll(() async {
    await CacheService().box.close();
    await storage.delete(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), null);
  });

  testWidgets(
    isSingleMode
        ? 'single mode login skips unavailable enterprise context and opens existing app'
        : 'successful login and failed context opens recovery; retry does not submit credentials again',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      Get.testMode = true;
      final original = EnterpriseService.instance;
      addTearDown(() async {
        EnterpriseService.replaceForTesting(original);
        Get.reset();
      });
      var status = 404;
      var requests = 0;
      EnterpriseService.replaceForTesting(
        EnterpriseService(
          baseUrl: 'https://test.invalid',
          token: () => 'test-session',
          client: MockClient((r) async {
            requests++;
            return status == 200
                ? http.Response(
                    jsonEncode({
                      'success': true,
                      'data': {'context': null},
                    }),
                    200,
                  )
                : http.Response('{}', status);
          }),
        ),
      );
      final auth = FakeAuth();
      final controller = Get.put(
        LoginController(authService: auth, profileService: FakeProfile()),
        permanent: true,
      );
      await tester.pumpWidget(
        GetMaterialApp(
          builder: (context, child) {
            ScreenUtil.init(context, designSize: const Size(390, 844));
            return child!;
          },
          getPages: [
            GetPage(
              name: AppRoute.bottonNavBar,
              page: () => const Scaffold(body: Text('Account opened')),
            ),
          ],
          home: Scaffold(
            body: Form(
              key: controller.loginFormKey,
              child: Column(
                children: [
                  TextFormField(controller: controller.emailController),
                  TextFormField(controller: controller.passwordController),
                  TextButton(
                    onPressed: controller.login,
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      controller.emailController.text = 'member@example.test';
      controller.passwordController.text = 'test-password';
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      if (isSingleMode) {
        expect(requests, 0);
        expect(auth.logins, 1);
        expect(find.text('Account opened'), findsOneWidget);
        expect(find.byType(EnterpriseAccessRecoveryScreen), findsNothing);
        expect(controller.passwordController.text, isEmpty);
        return;
      }
      expect(requests, 1);
      expect(auth.logins, 1);
      expect(find.byType(EnterpriseAccessRecoveryScreen), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(
        find.textContaining('not available on this server'),
        findsOneWidget,
      );
      expect(find.text('Account opened'), findsNothing);
      expect(controller.passwordController.text, isEmpty);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(auth.logins, 1);
      expect(find.byType(EnterpriseAccessRecoveryScreen), findsOneWidget);
      status = 200;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(auth.logins, 1);
      expect(find.text('Account opened'), findsOneWidget);
    },
  );

  test(
    'enterprise diagnostics include endpoint/status without query, token or response content',
    () async {
      final logs = <String>[];
      final service = EnterpriseService(
        baseUrl: 'https://api.test/api/v1',
        token: () => 'private-token',
        diagnostic: logs.add,
        client: MockClient((r) async => http.Response('private-response', 404)),
      );
      await expectLater(
        service.request('/enterprise/me/context?private=query'),
        throwsA(isA<EnterpriseException>()),
      );
      expect(
        logs.single,
        '[Enterprise] GET https://api.test/api/v1/enterprise/me/context: HTTP 404',
      );
    },
  );
}
