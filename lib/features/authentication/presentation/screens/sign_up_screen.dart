import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/app_logo.dart';
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
              AppLogoWidget(
                topPadding: 28.h,
                centerLogo: false,
                title: 'Sign up to  fitness',
              ),
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
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      labelText: 'First Name',
                      controller: controller.firstNameController,
                      hintText: "first name",
                       prefixIcon: Icon(Icons.person, size: 24.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: CustomTextField(
                      labelText: 'Last Name',
                      controller: controller.lastNameController,
                      hintText: "last name",
                      prefixIcon: Icon(Icons.person, size: 24.sp),
                    ),
                  ),
                ],
              ),
              CustomTextField(
                labelText: 'Gender',
                controller: controller.genderController,
                hintText: "Select gender",
                prefixIcon: Icon(
                  Icons.male,
                  size: 24.sp,
                ),
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  size: 24.sp,
                ),
              ),
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
              CustomTextField(
                labelText: 'Confirm Password',
                controller: controller.confirmPasswordController,
                hintText: "Confirm your password",
                prefixIcon: Icon(Icons.vpn_key, size: 24.sp),
                isPassword: true,
              ),
              SizedBox(height: 24.h),
              Obx(() {
                return CustomButton(
                  label: "Sign up",
                  onPressed: controller.register,
                  isLoading: controller.registerState.isLoading,
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
                      Get.back();
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

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),

    );
  }
}
