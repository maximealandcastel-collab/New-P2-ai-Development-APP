import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/reset_pass_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/app_logo.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ResetPassController.to;
    return CustomScaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: controller.resetFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppLogoWidget(
                centerLogo: false,
                title: 'Reset password',
              ),
              SizedBox(height: 40.h),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != controller.passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              SizedBox(height: 44.h),
              Obx(() {
                return CustomButton(
                  label: "Confirm",
                  onPressed: controller.resetPassword,
                  isLoading: controller.resetState.isLoading,
                );
              }),

              SizedBox(height: 18.h),
            ],
          ),
        ),
      ),
    );
  }
}
