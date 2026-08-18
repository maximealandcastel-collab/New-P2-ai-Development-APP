import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/constants/image_path.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/sign_up_screen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SingleChildScrollView(
        child: Form(
          key: controller.loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                ImagePath.splash3,
                width: 150.w,
                height: 150.h,
                fit: BoxFit.cover,
              ),
              CustomText(
                text: "Sign in to  fitness",
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
                      child: _helperTabBar(
                        text: "Trainer",
                        controller: controller,
                      ),
                    ),
                    Expanded(
                      child: _helperTabBar(
                        text: "User",
                        controller: controller,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
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
                final loading = controller.loginState == LoadingState.loading;
                return CustomButton(
                  label: "Sign in",
                  onPressed: loading ? null : () => controller.login(),
                  isLoading: loading,
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
                label: "Sign in with Google",
                onPressed: () {},
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
                text: "Don't have an account? ",
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              GestureDetector(
                onTap: () {
                  log("SignUp screen");
                  Get.to(() => SignUpScreen());
                },
                child: CustomText(
                  text: "Sign up",
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

Widget _helperTabBar({
  required String text,
  required LoginController controller,
}) {
  return Obx(
    () => GestureDetector(
      onTap: () => controller.setRole(text),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: controller.selectedRole == text
              ? AppColors.textPrimary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomText(
          color: controller.selectedRole == text
              ? AppColors.textWhite
              : AppColors.textSecondary,
          text: text,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
