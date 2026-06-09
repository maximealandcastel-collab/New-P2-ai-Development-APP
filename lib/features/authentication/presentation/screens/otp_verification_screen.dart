import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

import '../controllers/forget_pass_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ForgetPassController.to;

    return CustomScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ App Icon
            Image.asset(
              Assets.images.appIcon.path,
              width: 150.w,
              height: 150.h,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 6.h),

            // ✅ Title
            CustomText(
              text: "OTP verification",
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 40.h),

            // ✅ OTP Input Fields (6 fields)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                    (index) => OtpInputField(
                  controller: controller.otpControllers[index],
                  focusNode: controller.otpFocusNodes[index],
                  onChanged: (value) {
                    // সব field পূর্ণ হলে trigger করো (UI rebuild)
                    controller.handleOtpInput(value, index);
                  },
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // ✅ Resend OTP Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // Didn't get the code?
                  },
                  child: CustomText(
                    text: "Didn't got the code?",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                // ✅ Timer দেখান
                Obx(() {
                  final minutes = controller.remainingSeconds ~/ 60;
                  final seconds = controller.remainingSeconds % 60;
                  final formattedTime =
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

                  return controller.canResend
                      ? GestureDetector(
                    onTap: controller.resendOtp,
                    child: CustomText(
                      text: "Resend OTP",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  )
                      : CustomText(
                    text: "Resend in $formattedTime s",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.error,
                  );
                }),
              ],
            ),
            SizedBox(height: 32.h),

            // ✅ Verify OTP Button (শুধুমাত্র OTP complete হলে enable)
            Obx(() {
              final isComplete = controller.isOtpComplete;
              return CustomButton(
                label: "Verify OTP",
                onPressed: isComplete ? controller.verifyOtp : null,
                isLoading: controller.verifyOtpState.isLoading,
                // Button disable করো যদি OTP incomplete থাকে
                backgroundColor: isComplete
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.5),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ✅ Custom OTP Input Field Widget
class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const OtpInputField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45.w,
      height: 50.h,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        // শুধুমাত্র একটি সংখ্যা allow করো
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,
        ),
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}