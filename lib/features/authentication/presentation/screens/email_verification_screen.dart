import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

import '../controllers/forget_pass_controller.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ForgetPassController.to;

    return CustomScaffold(
      body: Form(
        key: controller.emailVerificationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              Assets.images.appIcon.path,
              width: 150.w,
              height: 150.h,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 6.h),
            CustomText(
              text: "Email verification",
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "Email",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 4.h),
                CustomTextField(
                  controller: controller.emailController,
                  hintText: "Enter your email address",
                  prefixIcon: Icon(Icons.email, size: 24.sp),
                ),
                SizedBox(height: 135.h),
                Obx(() {
                  return CustomButton(
                    label: "Send OTP",
                    onPressed: controller.verifyEmail,
                    // isLoading state দিয়েছো এবং controller এ আছে
                    isLoading: controller.verifyEmailState.isLoading,
                  );
                }),
              ],
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}