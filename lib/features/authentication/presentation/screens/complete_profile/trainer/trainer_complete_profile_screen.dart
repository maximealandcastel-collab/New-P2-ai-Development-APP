import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/children/bio_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/children/certifications_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/children/speciality_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/children/subscription_price_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/children/trainer_tags_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_flow_screen.dart';

class TrainerCompleteProfileScreen extends StatelessWidget {
  const TrainerCompleteProfileScreen({super.key});

  static const _pages = [
    BioPage(),
    CertificationsPage(),
    SpecialityPage(),
    TrainerTagsPage(),
    SubscriptionPricePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = ProfileCompleteController.to;

      return CompleteProfileFlowScreen(
        pages: _pages,
        formKey: controller.trainerFormKey,
        isLoading: controller.trainerState.isLoading,
        logoBottomSpacing: 40.h,
        onNextPressed: (currentIndex, navigateToPage, validateAfterNav) async {
          final formValid =
              controller.trainerFormKey.currentState?.validate() ?? false;
          if (!formValid) return;

          if (!controller.validateTrainerStep(currentIndex)) return;

          if (currentIndex < _pages.length - 1) {
            navigateToPage(currentIndex + 1);
            return;
          }

          for (var step = 0; step < _pages.length; step++) {
            if (!controller.validateTrainerStep(step)) {
              navigateToPage(step);
              return;
            }
            if (!controller.isTrainerTextStepValid(step)) {
              navigateToPage(step);
              validateAfterNav();
              return;
            }
          }

          controller.registerTrainer();
        },
      );
    });
  }
}
