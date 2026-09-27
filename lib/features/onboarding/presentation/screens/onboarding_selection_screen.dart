import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/themes/p2p_design_tokens.dart';
import 'package:pler_to_pler_app/core/utils/constants/image_path.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:pler_to_pler_app/features/onboarding/controller/onboarding_controller.dart';
import 'package:pler_to_pler_app/features/onboarding/presentation/widgets/onboarding_typography.dart';

class OnboardingSelectionScreen extends StatelessWidget {
  OnboardingSelectionScreen({super.key});

  final controller = Get.find<OnboardingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            ImagePath.onboarding4Bg,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  reverse: true,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: P2PResponsive.maxContentWidth),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Smarter Care.\nEffortless Workflow.",
                            textAlign: TextAlign.center,
                            style: OnboardingTypography.headline(context),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Get AI-guided plans, track progress, and stay connected to experts all in one platform.",
                              textAlign: TextAlign.center,
                              style: OnboardingTypography.description(context),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _helperSelection(
                                  context: context,
                                  onTap: () {
                                    log("Go to fitness login");
                                    Get.offAll(() => LoginScreen());
                                  },
                                  imagePath: ImagePath.splash3,
                                  title: 'Fitness',
                                  subTitle:
                                      'Personal workouts, trainer sessions,  plans and\nmore',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _helperSelection(
                                  context: context,
                                  onTap: () {
                                    log("Go to facility login");
                                    Get.offAll(() => LoginScreen());
                                  },
                                  imagePath: ImagePath.facilityAppLogo,
                                  title: 'Facility',
                                  subTitle:
                                      'Patient intake, scanning, AI rehab plans, clinician tools',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _helperSelection({
  required BuildContext context,
  required VoidCallback onTap,
  required String imagePath,
  required String title,
  required String subTitle,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.containerBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(title, style: OnboardingTypography.cardTitle(context)),
          const SizedBox(height: 5),
          Text(
            subTitle,
            style: OnboardingTypography.cardDescription(context),
          ),
        ],
      ),
    ),
  );
}
