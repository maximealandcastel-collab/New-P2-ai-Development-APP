import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
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
              SizedBox(height: 24.h),
              Image.asset(
                Assets.images.logo.path,
                width: 58.w,
                height: 58.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 22.h),
              CustomText(
                text: "Sign in to P2P Fitness",
                fontSize: 28.sp,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 10.h),
              CustomText(
                text: "Your fitness journey continues here!",
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 22.h),
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
                    Expanded(
                      child: TextButton(
                        onPressed: () =>
                            Get.toNamed(AppRoute.gymGatewayScreen),
                        child: Text(
                          'Gym',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              CustomText(
                text: "Email",
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: controller.emailController,
                hintText: "Enter your email address",
                prefixIcon: Icon(
                  Icons.email_outlined,
                  size: 22.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 20.h),
              CustomText(
                text: "Password",
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: controller.passwordController,
                hintText: "Enter your password",
                prefixIcon: Icon(
                  Icons.vpn_key_outlined,
                  size: 22.sp,
                  // color: Theme.of(context).colorScheme.primary,
                ),
                isPassword: true,
              ),
              SizedBox(height: 18.h),
              // "Save Login" — restored, and it is not cosmetic.
              //
              // LoginController already implements this in full: saveLogin is
              // persisted, restored on init, and is the ONLY thing that sets
              // 'sessionPersisted'. But the control had no UI, so saveLogin was
              // permanently false, 'sessionPersisted' was never written, and
              // SplashController's `if (!sessionPersisted) logout()` therefore
              // signed every non-owner account out on every single launch.
              // Nobody could stay logged in. The client's reference screenshot
              // has this checkbox; the newer build dropped it.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(
                    () => SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: Checkbox(
                        value: controller.saveLogin.value,
                        onChanged: (_) => controller.toggleSaveLogin(),
                        activeColor: Theme.of(context).colorScheme.primary,
                        side: const BorderSide(
                          color: AppColors.textSecondary,
                          width: 1.5,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: controller.toggleSaveLogin,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: 24.w,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CustomText(
                          text: "Save Login",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoute.forgotScreen),
                    child: CustomText(
                      text: "Forgot password?",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
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
                bordersColor: Colors.black.withValues(alpha: 0.008),
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/google_g.svg',
                      width: 18.r,
                      height: 18.r,
                    ),
                    SizedBox(width: 10.w),
                    CustomText(
                      text: 'Sign in with Google',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ],
                ),
                onPressed: () => Get.snackbar(
                  'Google sign-in',
                  'Google sign-in is not available yet. Please use email and password.',
                  snackPosition: SnackPosition.BOTTOM,
                ),
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
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
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
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
