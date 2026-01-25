import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_submit_button.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/common/widgets/custom_textformfield.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/core/utils/constants/image_path.dart';
import 'package:p2p_fitness/core/utils/validators/app_validator.dart';
import 'package:p2p_fitness/features/authentication/controllers/login_controller.dart';
import 'package:p2p_fitness/features/authentication/presentation/screens/sign_up_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final controller = Get.find<LoginController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(getHeight(16)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    ImagePath.appLogo,
                    width: getWidth(84),
                    height: getHeight(84),
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: getHeight(16)),
                  CustomText(
                    text: "Sign in to  fitness",
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(40)),
                  Container(
                    padding: EdgeInsets.all(getHeight(4)),
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
                        Expanded(
                          child: _helperTabBar(
                            text: "Facility",
                            controller: controller,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getHeight(24)),
                  CustomText(
                    text: "Email",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.textSecondary,
                  ),
                  SizedBox(height: getHeight(4)),
                  CustomTextFormField(
                    controller: controller.emailController,
                    hintText: "Enter your email address",
                    prefixIcon: Icon(Icons.email, size: 24.sp),
                    onChanged: (_) => controller.validateField(),
                    validation: AppValidator.validateEmail,
                  ),
                  SizedBox(height: getHeight(12)),
                  CustomText(
                    text: "Password",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.textSecondary,
                  ),
                  SizedBox(height: getHeight(4)),
                  Obx(
                    () => CustomTextFormField(
                      controller: controller.passwordController,
                      hintText: "Enter your password",
                      prefixIcon: Icon(Icons.vpn_key, size: 24.sp),
                      suffixIcon: GestureDetector(
                        onTap: () => controller.changeVisibility(),
                        child: Icon(
                          controller.passwordNotVisible.value == false
                              ? Icons.visibility_rounded
                              : Icons.visibility_off,
                          size: 24.sp,
                        ),
                      ),
                      obscureText: controller.passwordNotVisible.value,
                      onChanged: (_) => controller.validateField(),
                      validation: AppValidator.validatePassword,
                    ),
                  ),
                  SizedBox(height: getHeight(12)),
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
                        textColor: AppColors.textSecondary,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(24)),
                  Obx(
                    () => CustomSubmitButton(
                      text: "Sign in",
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          log("Validate");
                        } else {
                          log("Not validate");
                        }
                      },
                      textColor: controller.isValidate.value
                          ? AppColors.textWhite
                          : AppColors.textSecondary,
                      color: controller.isValidate.value
                          ? AppColors.primary
                          : AppColors.textFormFieldBorder,
                    ),
                  ),
                  SizedBox(height: getHeight(16)),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      SizedBox(width: getWidth(8)),
                      CustomText(
                        text: "Or continue with",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        textColor: AppColors.textSecondary,
                      ),
                      SizedBox(width: getWidth(8)),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: getHeight(16)),
                  CustomSubmitButton(
                    text: "Sign in with Google",
                    onTap: () {},
                    textColor: AppColors.textPrimary,
                    color: AppColors.textWhite,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(getHeight(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: "Don’t have an account? ",
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                textColor: AppColors.textSecondary,
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
                  textColor: AppColors.primary,
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
      onTap: () {
        controller.changeTab(text);
      },
      child: Container(
        padding: EdgeInsets.all(getHeight(10)),
        decoration: BoxDecoration(
          color: controller.selectedTab.value == text
              ? AppColors.textPrimary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomText(
          text: text,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          textColor: controller.selectedTab.value == text
              ? AppColors.textWhite
              : AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
