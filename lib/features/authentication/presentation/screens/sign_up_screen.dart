import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/login_screen.dart';
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
                Assets.images.appIcon.path,
                width: 150.w,
                height: 150.h,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 6.h),
              CustomText(
                text: "Sign up to  fitness",
                fontSize: 32.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 21.h),
              Row(
                children: [
                  Expanded(
                      flex:25,
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "First name",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 4.h),
                      CustomTextField(
                        controller: controller.firstName,
                        hintText: "first name",
                       // prefixIcon: Icon(Icons.email, size: 24.sp),
                      ),
                    ],
                  )),
                  Spacer(flex: 5,),
                  Expanded(
                      flex: 25,
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Last name",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 4.h),
                      CustomTextField(
                        controller: controller.lastName,
                        hintText: "last name",
                       // prefixIcon: Icon(Icons.email, size: 24.sp),
                      ),
                    ],
                  )),
                ],
              ),
              SizedBox(height: 2.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Gender",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 4.h),
                  DropdownButtonFormField<String>(
                    value: controller.gender.text.isEmpty
                        ? null
                        : controller.gender.text,

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select gender';
                      }
                      return null;
                    },

                    decoration: InputDecoration(
                      hintText: "Select gender",

                      prefixIcon: Icon(
                        Icons.male,
                        size: 24.sp,
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.grey.shade500,
                        ),
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),

                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                    ),

                    icon: const SizedBox.shrink(),

                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),

                    items: [
                      DropdownMenuItem(
                        value: "Male",
                        child: Text(
                          "Male",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Female",
                        child: Text(
                          "Female",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Other",
                        child: Text(
                          "Other",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],

                    onChanged: (value) {
                      if (value != null) {
                        controller.gender.text = value;
                      }
                    },
                  ),
                  SizedBox(height: 6.h),
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
                  SizedBox(height: 2.h),
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

                  SizedBox(height: 2.h),
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
                  Obx(() {
                    return CustomButton(
                      label: "Sign up",
                      onPressed: controller.register,
                      isLoading: controller.registerState.isLoading,
                    );
                  }),
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
