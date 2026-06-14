import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/onboarding/controller/onboarding_controller.dart';
import 'package:pler_to_pler_app/features/onboarding/model/onboarding_item_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

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
                    left: 16.w,
                    right: 16.w,
                    bottom: 180.h,
                    child: Column(
                      children: [
                        CustomText(
                          text: item.title,
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
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
            left: 16.w,
            right: 16.w,
            bottom: 16.h,
            child: SafeArea(
              child: Column(
                children: [
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingList.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          height: 10.r,
                          width: controller.currentIndex.value == index
                              ? 40.r
                              : 10.r,
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

                  SizedBox(height: 36.h),

                  CustomButton(label: "Next", onPressed: controller.nextPage),
                ],
              ),
            ),
          ),
          Positioned(
            top: 70.h,
            right: 26.w,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                log("Skip");
                Get.offAllNamed(AppRoute.loginScreen);
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
