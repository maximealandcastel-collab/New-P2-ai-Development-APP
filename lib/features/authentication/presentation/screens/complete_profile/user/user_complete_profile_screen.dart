import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/children/additional_info_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/children/gym_info_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/children/goal_setup_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/children/physical_info_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_flow_screen.dart';

class UserCompleteProfileScreen extends StatelessWidget {
  const UserCompleteProfileScreen({super.key});

  static const _pages = [
    GoalSetupPage(),
    PhysicalInfoPage(),
    GymInfoPage(),
    AdditionalInfoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = ProfileCompleteController.to;

      return CompleteProfileFlowScreen(
        pages: _pages,
        formKey: controller.userFormKey,
        isLoading: controller.userState.isLoading,
        onNextPressed: (currentIndex, navigateToPage, validateAfterNav) async {
          final formValid =
              controller.userFormKey.currentState?.validate() ?? false;
          if (!formValid) return;

          if (currentIndex < _pages.length - 1) {
            navigateToPage(currentIndex + 1);
            return;
          }

          for (var step = 0; step < _pages.length; step++) {
            if (!controller.isUserTextStepValid(step)) {
              navigateToPage(step);
              validateAfterNav();
              return;
            }
          }

          controller.registerUser();
        },
      );
    });
  }
}
