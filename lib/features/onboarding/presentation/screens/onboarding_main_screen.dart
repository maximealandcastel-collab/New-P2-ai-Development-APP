import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/onboarding/controller/onboarding_controller.dart';
import 'package:pler_to_pler_app/features/onboarding/model/onboarding_item_model.dart';
import 'package:pler_to_pler_app/features/onboarding/presentation/widgets/onboarding_typography.dart';
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
                    left: 28.w,
                    right: 28.w,
                    bottom: 184.h,
                    child: Column(
                      children: [
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: OnboardingTypography.headline(context),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: OnboardingTypography.description(context),
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
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          height: 6.r,
                          width: controller.currentIndex.value == index
                              ? 34.r
                              : 6.r,
                          decoration: BoxDecoration(
                            color: controller.currentIndex.value == index
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  CustomButton(
                    label: "Next",
                    height: 54.h,
                    radius: 18.r,
                    fontSize: OnboardingTypography.action(context).fontSize,
                    fontWeight: FontWeight.w500,
                    onPressed: controller.nextPage,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 18.h,
            right: 20.w,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                log("Skip");
                Get.offAllNamed(AppRoute.smarterCareScreen);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Text(
                  "Skip",
                  style: OnboardingTypography.action(context).copyWith(
                    color: const Color(0xFF343438),
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
