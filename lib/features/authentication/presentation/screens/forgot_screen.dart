import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/forget_pass_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/app_logo.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ForgotScreen extends StatelessWidget {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ForgetController.to;

    return CustomScaffold(
      appBar: CustomAppBar(),
      body: Form(
        key: controller.forgotFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppLogoWidget(
              centerLogo: false,
              title: 'Forgot Password',
            ),
            SizedBox(height: 44.h),
            CustomTextField(
              keyboardType: TextInputType.emailAddress,
              controller: controller.emailController,
              hintText: "Enter your email address",
              prefixIcon: Icon(Icons.email, size: 24.sp),
            ),
            SizedBox(height: 32.h),
            Obx(() {
              return CustomButton(
                label: "Send OTP",
                onPressed: controller.forgot,
                isLoading: controller.forgotState.isLoading,
              );
            }),
          ],
        ),
      ),
    );
  }
}