import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/app_logo.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/tap_bar_helper.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoginController.to;
    return CustomScaffold(
      body: SingleChildScrollView(
        child: Form(
          key: controller.loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppLogoWidget(
                topPadding: 28.h,
                centerLogo: false,
                title: 'Sign in to  fitness',
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
                    Expanded(child: TapBarHelper(text: "Trainer")),
                    Expanded(child: TapBarHelper(text: "User")),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              CustomTextField(
                labelText: 'Email',
                controller: controller.emailController,
                hintText: "Enter your email address",
                prefixIcon: Icon(Icons.email, size: 24.sp),
              ),
              CustomTextField(
                labelText: 'Password',
                controller: controller.passwordController,
                hintText: "Enter your password",
                prefixIcon: Icon(Icons.vpn_key, size: 24.sp),
                isPassword: true,
              ),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Get.toNamed(AppRoute.forgotScreen);
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
                  label: "Sign in",
                 // onPressed: controller.login,
                  onPressed: () {
                    Get.toNamed(AppRoute.trainerCompleteProfileScreen);
                  },
                  isLoading: controller.loginState.isLoading,
                );
              }),

              SizedBox(height: 18.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: "Don’t have an account? ",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.toNamed(AppRoute.signUpScreen);
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
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
