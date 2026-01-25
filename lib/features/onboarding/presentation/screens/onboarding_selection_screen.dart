import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/core/utils/constants/image_path.dart';
import 'package:p2p_fitness/features/authentication/presentation/screens/login_screen.dart';
import 'package:p2p_fitness/features/onboarding/controller/onboarding_controller.dart';

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
          Positioned(
            left: getWidth(16),
            right: getWidth(16),
            bottom: getHeight(46),
            child: Column(
              children: [
                CustomText(
                  text: "Smarter care. effortless workflow",
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: getHeight(8)),
                CustomText(
                  text:
                      "Get AI-guided plans, track progress, and stay connected to experts all in one platform.",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: getHeight(40)),
                Row(
                  children: [
                    Expanded(
                      child: _helperSelection(
                        onTap: () {
                          log("Go to fitness login");
                          Get.offAll(() => LoginScreen());
                        },
                        imagePath: ImagePath.appLogo,
                        title: 'Fitness',
                        subTitle:
                            'Personal workouts, trainer sessions,  plans and\nmore',
                      ),
                    ),
                    SizedBox(width: getWidth(8)),
                    Expanded(
                      child: _helperSelection(
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
        ],
      ),
    );
  }
}

Widget _helperSelection({
  required VoidCallback onTap,
  required String imagePath,
  required String title,
  required String subTitle,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(getHeight(16)),
      decoration: BoxDecoration(
        color: AppColors.containerBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: getWidth(64),
            height: getHeight(64),
            fit: BoxFit.cover,
          ),
          SizedBox(height: getHeight(8)),
          CustomText(text: title, fontSize: 16.sp, fontWeight: FontWeight.w600),
          SizedBox(height: getHeight(8)),
          CustomText(
            text: subTitle,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    ),
  );
}
