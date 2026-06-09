import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/forget_pass_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/otp_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/app_logo.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OtpController.to;

    return CustomScaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: controller.otpFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            AppLogoWidget(
              centerLogo: false,
              title: 'OTP Verification',
            ),
              SizedBox(height: 40.h),


              Center(
                child: CustomPinCodeTextField(
                  controller: controller.otpController,

                ),
              ),
              SizedBox(height: 16.h,),
              Obx(() {
                final controller = ForgetController.to;
                return Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(text:
                      "Didn't receive the code?  ",
                        color: AppColors.textSecondary,

                      ),
                      controller.canResend
                          ? GestureDetector(
                        onTap: () => controller.resendOtp(),
                        child: CustomText(text:
                        'Resend',
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      )
                          : CustomText(text:
                      'Resend in ${controller.resendSeconds}s',
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 32.h),
              Obx(() {
                return CustomButton(
                  label: "Send OTP",
                  onPressed: _onTapNextScreen,
                  isLoading: controller.otpState.isLoading,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapNextScreen() async {
    final success = await OtpController.to.otpVerify();
    if (success) {
      if((Get.arguments ?? '') == 'signup') {
        //Get.offNamed(AppRoute.completeProfileFirstScreen);
      } else {
        //Get.offNamed(AppRoute.resetPasswordScreen);
      }
    }
  }
}
