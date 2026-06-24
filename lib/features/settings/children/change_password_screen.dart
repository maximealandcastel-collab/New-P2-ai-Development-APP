import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/change_password_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ChangePasswordController.to;

    return CustomScaffold(
      appBar: CustomAppBar(title: 'Change Password'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              CustomText(
                top: 24.h,
                text:
                    'Enter your current password and choose a new secure password.',
                color: Colors.grey,
                fontSize: 13.sp,
                bottom: 16.h,
                textAlign: TextAlign.start,
              ),
              CustomTextField(
                prefixIcon: Assets.icons.passwordIcon.image(
                  height: 20.r,
                  width: 20.r,
                ),
                labelText: 'Current password',
                hintText: 'Enter your current password',
                controller: controller.oldPasswordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              CustomTextField(
                prefixIcon: Assets.icons.passwordIcon.image(
                  height: 20.r,
                  width: 20.r,
                ),
                labelText: 'New password',
                hintText: 'Enter your new password',
                controller: controller.newPasswordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              CustomTextField(
                prefixIcon: Assets.icons.passwordIcon.image(
                  height: 20.r,
                  width: 20.r,
                ),
                labelText: 'Confirm new password',
                hintText: 'Confirm your new password',
                controller: controller.confirmPasswordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != controller.newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.h),
              Obx(
                () => CustomButton(
                  label: 'Save',
                  onPressed: controller.changePassword,
                  isLoading: controller.changePasswordState.isLoading,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
