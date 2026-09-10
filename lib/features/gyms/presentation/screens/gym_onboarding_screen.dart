import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/member_signup/member_signup_screen.dart';
import 'gym_welcome_screen.dart';

class GymOnboardingScreen extends StatelessWidget {
  final bool gymEntry;
  const GymOnboardingScreen({super.key, this.gymEntry = false});

  @override
  Widget build(BuildContext context) => GymWelcomeScreen(
    gymEntry: gymEntry,
    onMember: () => Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MemberSignupScreen())),
  );
}
