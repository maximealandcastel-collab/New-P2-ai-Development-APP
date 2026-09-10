import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/member_signup/member_signup_screen.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gym_onboarding_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';

class FakeAuth extends Fake implements AuthService {}

class FakeProfile extends Fake implements ProfileService {}

void main() {
  Future<void> tap(WidgetTester tester, Finder finder) async {
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      finder,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) =>
      tap(tester, find.widgetWithText(FilledButton, 'Continue ➜'));
  void mobile(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => Get.reset());
  }

  Future<void> details(WidgetTester tester) async {
    await tester.enterText(find.byKey(const ValueKey('FIRST NAME')), 'Alex');
    await tester.enterText(find.byKey(const ValueKey('LAST NAME')), 'Johnson');
    await tester.enterText(
      find.byKey(const ValueKey('EMAIL ADDRESS')),
      'alex@example.com',
    );
    await next(tester);
  }

  testWidgets('Member path opens first signup step', (tester) async {
    mobile(tester);
    await tester.pumpWidget(const MaterialApp(home: GymOnboardingScreen()));
    await tester.pumpAndSettle();
    await tap(tester, find.text('Member'));
    await next(tester);
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(find.byKey(const ValueKey('FIRST NAME')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'email validation blocks invalid entry and Back preserves details',
    (tester) async {
      mobile(tester);
      await tester.pumpWidget(const MaterialApp(home: MemberSignupScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('FIRST NAME')), 'Alex');
      await tester.enterText(
        find.byKey(const ValueKey('LAST NAME')),
        'Johnson',
      );
      await tester.enterText(
        find.byKey(const ValueKey('EMAIL ADDRESS')),
        'invalid',
      );
      await next(tester);
      expect(find.text('Enter a valid email'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('EMAIL ADDRESS')),
        'alex@example.com',
      );
      await next(tester);
      expect(find.text('Step 2 of 5'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Continue ➜'),
        180,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Continue ➜'),
            )
            .onPressed,
        isNull,
      );
      await tester.scrollUntilVisible(find.text('Back'), -180);
      await tap(tester, find.text('Back'));
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('FIRST NAME')))
            .controller!
            .text,
        'Alex',
      );
      expect(find.text('alex@example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final selectedGym in ['No gym', 'LA Fitness', 'KMF Fitness Club']) {
    testWidgets('five steps preserve profile and handle $selectedGym', (
      tester,
    ) async {
      mobile(tester);
      Map? destination;
      await tester.pumpWidget(
        GetMaterialApp(
          home: const MemberSignupScreen(),
          getPages: [
            GetPage(
              name: AppRoute.paywallScreen,
              page: () {
                destination = Get.arguments as Map;
                return const Scaffold(body: Text('Account setup'));
              },
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await details(tester);
      await tap(tester, find.text('Non-binary'));
      await next(tester);
      expect(find.text('Step 3 of 5'), findsOneWidget);
      await tap(tester, find.text('Weight Loss'));
      await tap(tester, find.text('Build Muscle'));
      await next(tester);
      expect(find.text('Step 4 of 5'), findsOneWidget);
      await tap(
        tester,
        selectedGym == 'No gym'
            ? find.text('No gym — Continue with P2P Fit Tech AI')
            : find.text(selectedGym),
      );
      if (selectedGym == 'No gym') {
        expect(find.text("You're heading to\nP2P Fit Tech AI"), findsOneWidget);
        await tap(tester, find.text('Pick a gym instead'));
        expect(
          find.text('No gym — Continue with P2P Fit Tech AI'),
          findsOneWidget,
        );
        await next(tester);
        expect(find.text("You're heading to\nP2P Fit Tech AI"), findsOneWidget);
        await tap(tester, find.text('Back to gym selection'));
        expect(
          find.text('No gym — Continue with P2P Fit Tech AI'),
          findsOneWidget,
        );
        await next(tester);
        await tap(tester, find.text('Go to P2P Fit Tech AI ➜'));
        expect(find.text('Step 5 of 5'), findsOneWidget);
        expect(find.text('Welcome,\nAlex!'), findsOneWidget);
        expect(find.text('P2P FIT TECH AI'), findsOneWidget);
        expect(find.text('Gym'), findsNothing);
        expect(destination, isNull);
        await tap(tester, find.text('Go to My Dashboard ➜'));
      } else {
        await next(tester);
        expect(find.text('Step 5 of 5'), findsOneWidget);
        expect(find.text('Welcome,\nAlex!'), findsOneWidget);
        expect(find.text('Weight Loss, Build Muscle'), findsOneWidget);
        expect(find.textContaining('membership is connected'), findsNothing);
        await tap(tester, find.text('Continue to Create Account ➜'));
      }
      expect(find.text('Account setup'), findsOneWidget);
      final arguments = destination!['nextArguments'] as Map;
      final draft = arguments['memberDraft'] as Map;
      expect(draft['firstName'], 'Alex');
      expect(draft['gender'], 'Non-binary');
      expect(draft['heightInches'], 68);
      expect(draft['weightLbs'], 165);
      expect(draft['goals'], ['Lose Weight', 'Build Muscle']);
      expect(
        arguments['tenantId'],
        selectedGym == 'KMF Fitness Club' ? 'kmf-fitness' : null,
      );
      expect(
        arguments['gymName'],
        selectedGym == 'No gym' ? null : selectedGym,
      );
      expect(tester.takeException(), isNull);
    });
  }

  test('signup and profile completion receive the collected draft', () {
    final draft = {
      'firstName': 'Alex',
      'lastName': 'Johnson',
      'email': 'alex@example.com',
      'gender': 'Non-binary',
      'heightInches': 68,
      'weightLbs': 165,
      'goals': ['Lose Weight', 'Build Muscle'],
    };
    final signup = SignUpController(authService: FakeAuth());
    signup.configureEntry({'paywallPassed': true, 'memberDraft': draft});
    expect(signup.firstNameController.text, 'Alex');
    expect(signup.genderController.text, 'Non-binary');
    final profile = ProfileCompleteController(
      authService: FakeAuth(),
      profileService: FakeProfile(),
    );
    profile.applyMemberDraft(draft);
    expect(profile.heightController.text, '5\'8" (173 cm)');
    expect(profile.weightController.text, '165 lb');
    expect(profile.onboardingGoals, ['Lose Weight', 'Build Muscle']);
    expect(profile.primaryGoalController.text, 'Lose Weight');
    profile.onClose();
    signup.dispose();
  });
}
