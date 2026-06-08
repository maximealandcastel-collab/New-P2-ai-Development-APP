import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/constants/image_path.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/tap_bar_helper.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SignUpController.to;

    return CustomScaffold(
      body: SingleChildScrollView(
        child: Form(
          key: controller.registerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                ImagePath.splash3,
                width: 150.w,
                height: 150.h,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: "Sign up to  fitness",
                fontSize: 32.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 40.h),
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: AppColors.textWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TapBarHelper(
                        text: "Trainer",
                      ),
                    ),
                    Expanded(
                      child: TapBarHelper(
                        text: "User",
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
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
                  SizedBox(height: 12.h),
                  CustomText(
                    text: "Password",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 4.h),
                  CustomTextField(
                    controller: controller.passwordController,
                    hintText: "Enter your password",
                    prefixIcon: Icon(Icons.vpn_key, size: 24.sp),
                    isPassword: true,
                  ),

                  SizedBox(height: 12.h),
                  CustomText(
                    text: "Confirm password",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 4.h),
                  CustomTextField(
                    controller: controller.confirmPasswordController,
                    hintText: "Enter your password",
                    prefixIcon: Icon(Icons.vpn_key, size: 24.sp),
                    isPassword: true,
                  ),

                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        log("Forgot password click");
                      },
                      child: CustomText(
                        text: "Forgot password?",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Obx(() {
                    return CustomButton(
                      label: "Sign up",
                      onPressed: controller.register,
                      isLoading: controller.registerState.isLoading,
                    );
                  }),

                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      SizedBox(width: 8.w),
                      CustomText(
                        text: "Or continue with",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  CustomButton(
                    bordersColor: Colors.black.withOpacity(0.008),
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    label: "Sign up with Google",
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: "Don’t have an account? ",
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              GestureDetector(
                onTap: () {
                  log("Sign in screen");
                  Get.to(() => LoginScreen());
                },
                child: CustomText(
                  text: "Sign in",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
