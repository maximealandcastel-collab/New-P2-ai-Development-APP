import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/features/user/user_profile/presentation/user_profile_screen.dart'
    as community_profile;

/// Named-route entry point for the subscriber profile.
///
/// The visual profile and community hub lives in the user feature so direct
/// avatar taps and named-route navigation always open the same experience.
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const community_profile.UserProfileScreen();
}
