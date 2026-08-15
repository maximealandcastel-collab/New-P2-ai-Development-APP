import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/affiliate_mode_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/affiliate/presentation/controllers/affiliate_dashboard_controller.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/paywall/presentation/screens/paywall_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/app_logo.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/auth_switch_link.dart';
import 'package:pler_to_pler_app/features/nav_bar/presentation/screens/nav_bar.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoginController.to;
    return CustomScaffold(
      body: SingleChildScrollView(
        child: AutofillGroup(
        child: Form(
          key: controller.loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppLogoWidget(
                topPadding: 44.h,
                centerLogo: false,
                title: 'Sign in to  fitness',
                subtitle: 'Your fitness journey continues here!',
              ),
              SizedBox(height: 24.h),
              // Container(
              //   padding: EdgeInsets.all(4.r),
              //   decoration: BoxDecoration(
              //     color: AppColors.textWhite,
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: Row(
              //     children: [
              //       Expanded(child: TapBarHelper(text: "Trainer")),
              //       Expanded(child: TapBarHelper(text: "User")),
              //     ],
              //   ),
              // ),
              //SizedBox(height: 24.h),
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
              // ── Save Login  +  Forgot password row ───────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Row(
                  children: [
                    // Save Login checkbox
                    Obx(() => GestureDetector(
                      onTap: controller.toggleSaveLogin,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: controller.saveLogin.value
                                  ? AppColors.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: controller.saveLogin.value
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: controller.saveLogin.value
                                ? Icon(Icons.check,
                                    size: 14.sp, color: Colors.white)
                                : null,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Save Login',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Spacer(),
                    // Forgot password
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Get.toNamed(AppRoute.forgotScreen),
                      child: CustomText(
                        text: "Forgot password?",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Obx(() {
                return CustomButton(
                  label: "Sign in",
                  onPressed: controller.login,
                  // onPressed: () {
                  //   Get.toNamed(AppRoute.trainerCompleteProfileScreen);
                  // },
                  isLoading: controller.loginState.isLoading,
                );
              }),

              SizedBox(height: 18.h),
              AuthSwitchLink(
                prompt: "Don't have an account? ",
                actionLabel: 'Sign up',
                onTap: () => Get.to(() => PaywallScreen()),
              ),
              SizedBox(height: 24.h),

              // ── Partner / Affiliate login ──────────────────────────
              GestureDetector(
                onTap: () => _showPartnerLogin(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.handshake_outlined,
                      size: 14.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Partner / Affiliate Login',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _showPartnerLogin(BuildContext context) {
    final codeController = TextEditingController();
    final loading = false.obs;
    final error = ''.obs;

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.handshake_outlined,
                      color: AppColors.primary, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Partner Login',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close,
                        size: 20.sp, color: Colors.grey.shade500),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'Enter your partner code to access your earnings dashboard.',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                obscureText: true,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp, letterSpacing: 6),
                decoration: InputDecoration(
                  hintText: '• • • • •',
                  hintStyle: TextStyle(
                    fontSize: 18.sp,
                    letterSpacing: 6,
                    color: Colors.grey.shade400,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 16.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              Obx(() => error.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        error.value,
                        style: TextStyle(
                            color: Colors.red.shade400, fontSize: 12.sp),
                      ),
                    )
                  : const SizedBox.shrink()),
              SizedBox(height: 20.h),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: loading.value
                          ? null
                          : () async {
                              final code =
                                  codeController.text.trim().toUpperCase();
                              if (code.isEmpty) {
                                error.value = 'Please enter your partner code';
                                return;
                              }
                              loading.value = true;
                              error.value = '';
                              await Future.delayed(
                                  const Duration(milliseconds: 350));
                              loading.value = false;

                              if (code == '67') {
                                if (!Get.isRegistered<AffiliateModeService>()) {
                                  Get.put(AffiliateModeService(), permanent: true);
                                }
                                AffiliateModeService.to.activate(code);
                                if (!Get.isRegistered<AffiliateDashboardController>()) {
                                  Get.put(AffiliateDashboardController(
                                      promoCode: code));
                                }
                                Get.back(); // close sheet
                                Get.snackbar(
                                  '💰 Partner Access Activated',
                                  'Welcome Samir! Your earnings dashboard is ready.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF1A1A2E),
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 3),
                                );
                                Get.offAll(() => NavBar());
                              } else {
                                error.value = 'Invalid partner code.';
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: loading.value
                          ? SizedBox(
                              width: 22.w,
                              height: 22.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Access Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

