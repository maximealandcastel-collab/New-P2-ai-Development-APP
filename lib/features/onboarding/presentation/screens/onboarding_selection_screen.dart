import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/constants/image_path.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:pler_to_pler_app/features/onboarding/controller/onboarding_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

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
            left: 16.w,
            right: 16.w,
            bottom: 46.h,
            child: Column(
              children: [
                CustomText(
                  text: "Smarter care. effortless workflow",
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text:
                      "Get AI-guided plans, track progress, and stay connected to experts all in one platform.",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: 40.h),
                Row(
                  children: [
                    Expanded(
                      child: _helperSelection(
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
                    SizedBox(width: 8.w),
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.containerBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: 64.w,
            height: 64.h,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8.h),
          CustomText(text: title, fontSize: 16.sp, fontWeight: FontWeight.w600),
          SizedBox(height: 8.h),
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
