import 'dart:developer';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_dropdown.dart';
import 'package:p2p_fitness/core/common/widgets/custom_submit_button.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/common/widgets/custom_textformfield.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/core/utils/constants/image_path.dart';
import 'package:p2p_fitness/core/utils/validators/app_validator.dart';
import 'package:p2p_fitness/features/authentication/controllers/sign_up_controller.dart';
import 'package:p2p_fitness/features/authentication/presentation/screens/login_screen.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/presentation/screens/trainer_and_user_set_up_profile.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final controller = Get.find<SignUpController>();
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
                    text: "Sign up to  fitness",
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
                  Obx(() {
                    if (controller.selectedTab.value == "Facility") {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "Facility name",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            textColor: AppColors.textSecondary,
                          ),
                          SizedBox(height: getHeight(4)),
                          CustomTextFormField(
                            controller: controller.facilityNameController,
                            hintText: "Enter your facility name",
                            prefixIcon: Icon(Icons.factory, size: 24.sp),
                            onChanged: (_) =>
                                controller.validateFieldFacility(),
                            // validation: AppValidator.validateNotEmpty,
                          ),
                          SizedBox(height: getHeight(12)),
                          CustomText(
                            text: "Facility type",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            textColor: AppColors.textSecondary,
                          ),
                          SizedBox(height: getHeight(4)),
                          Obx(
                            () => CustomDropdownField(
                              hintText: "Select a facility type",
                              items: controller.facilityList,
                              selectedValue:
                                  controller.selectedFacilityType.value,
                              onChanged: (value) {
                                controller.changeFacilityType(value);
                                controller.validateFieldFacility();
                              },
                              borderRedius: 16,
                            ),
                          ),
                          SizedBox(height: getHeight(12)),
                          CustomText(
                            text: "Facility Registration/Accreditation number",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            textColor: AppColors.textSecondary,
                          ),
                          SizedBox(height: getHeight(4)),
                          CustomTextFormField(
                            controller:
                                controller.facilityAccountNumberController,
                            hintText: "000-000-000-0000",
                            // prefixIcon: Icon(Icons.factory, size: 24.sp),
                            onChanged: (_) =>
                                controller.validateFieldFacility(),
                            // validation: AppValidator.validateNotEmpty,
                            keyboardType: TextInputType.numberWithOptions(),
                          ),
                          SizedBox(height: getHeight(12)),
                          GestureDetector(
                            onTap: () {
                              controller.pickFile();
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(12),
                              dashPattern: const [5, 4],
                              color: AppColors.textSecondary,
                              strokeWidth: 1,
                              child: Padding(
                                padding: EdgeInsets.all(getHeight(16)),
                                child: Obx(() {
                                  if (controller.filePath.value.isNotEmpty) {
                                    return Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(
                                            getHeight(12),
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.textWhite,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.file_copy,
                                            size: 24.sp,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(width: getWidth(14)),
                                        Expanded(
                                          child: CustomText(
                                            text: controller.filePath.value,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: getWidth(12)),
                                        GestureDetector(
                                          onTap: () {
                                            controller.filePath.value = "";
                                            controller.validateFieldFacility();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(
                                              getHeight(12),
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.textWhite,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              CupertinoIcons.delete,
                                              size: 24.sp,
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(getHeight(12)),
                                        decoration: BoxDecoration(
                                          color: AppColors.textWhite,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 24.sp,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(width: getWidth(14)),
                                      CustomText(
                                        text:
                                            "Trade license /\nAccreditation certificate",
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                          SizedBox(height: getHeight(24)),
                          CustomSubmitButton(
                            text: "Continue",
                            onTap: () {
                              if (controller.isValidateFacility.value) {
                                log("Validate user");
                              } else {
                                log("Invalid user");
                              }
                            },
                            textColor: controller.isValidateFacility.value
                                ? AppColors.textWhite
                                : AppColors.textSecondary,
                            color: controller.isValidateFacility.value
                                ? AppColors.primary
                                : AppColors.textFormFieldBorder,
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        CustomText(
                          text: "Confirm password",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          textColor: AppColors.textSecondary,
                        ),
                        SizedBox(height: getHeight(4)),
                        Obx(
                          () => CustomTextFormField(
                            controller: controller.conPasswordController,
                            hintText: "Enter your password",
                            prefixIcon: Icon(Icons.vpn_key, size: 24.sp),
                            suffixIcon: GestureDetector(
                              onTap: () => controller.changeVisibility2(),
                              child: Icon(
                                controller.passwordNotVisible2.value == false
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off,
                                size: 24.sp,
                              ),
                            ),
                            obscureText: controller.passwordNotVisible2.value,
                            onChanged: (_) => controller.validateField(),
                            validation: (value) =>
                                AppValidator.validateConfirmPassword(
                                  value,
                                  controller.passwordController.text,
                                ),
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
                            text: "Sign up",
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                Get.offAll(() => TrainerAndUserSetUpProfile());
                                log("Validate");
                              } else {
                                Get.offAll(() => TrainerAndUserSetUpProfile());
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
                          text: "Sign up with Google",
                          onTap: () {},
                          textColor: AppColors.textPrimary,
                          color: AppColors.textWhite,
                        ),
                      ],
                    );
                  }),
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
                  log("Sign in screen");
                  Get.to(() => LoginScreen());
                },
                child: CustomText(
                  text: "Sign in",
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
  required SignUpController controller,
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
