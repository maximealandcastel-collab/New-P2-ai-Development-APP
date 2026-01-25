import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_submit_button.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/features/onboarding/controller/onboarding_controller.dart';
import 'package:p2p_fitness/features/onboarding/model/onboarding_item_model.dart';
import 'package:p2p_fitness/features/onboarding/presentation/screens/onboarding_selection_screen.dart';

class OnboardingMainScreen extends StatelessWidget {
  OnboardingMainScreen({super.key});

  final controller = Get.find<OnboardingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            itemCount: onboardingList.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              final item = onboardingList[index];
              return Stack(
                children: [
                  Image.asset(
                    item.image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: getWidth(16),
                    right: getWidth(16),
                    bottom: getHeight(180),
                    child: Column(
                      children: [
                        CustomText(
                          text: item.title,
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: getHeight(8)),
                        CustomText(
                          text: item.subtitle,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          Positioned(
            left: getWidth(16),
            right: getWidth(16),
            bottom: getHeight(16),
            child: SafeArea(
              child: Column(
                children: [
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingList.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: getWidth(6)),
                          height: getHeight(10),
                          width: controller.currentIndex.value == index
                              ? getWidth(40)
                              : getWidth(8),
                          decoration: BoxDecoration(
                            color: controller.currentIndex.value == index
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: getHeight(36)),

                  CustomSubmitButton(text: "Next", onTap: controller.nextPage),
                ],
              ),
            ),
          ),
          Positioned(
            top: getHeight(80),
            right: getWidth(26),
            child: GestureDetector(
              onTap: () {
                log("Skip");
                Get.offAll(() => OnboardingSelectionScreen());
              },
              child: CustomText(
                text: "Skip",
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
