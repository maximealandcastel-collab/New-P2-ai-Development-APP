import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/features/paywall/controllers/paywall_controller.dart';
import 'package:pler_to_pler_app/features/nav_bar/presentation/screens/nav_bar.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallScreen extends StatelessWidget {
  PaywallScreen({super.key});

  final controller = Get.find<PaywallController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F2),
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          margin: EdgeInsets.only(top: 8.h),
                          padding: EdgeInsets.all(8.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close,
                              size: 20.sp, color: AppColors.textPrimary),
                        ),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Logo
                    Image.asset(
                      'assets/images/app_logo.png',
                      height: 90.h,
                      errorBuilder: (context, error, stack) => Icon(
                        Icons.fitness_center,
                        size: 64.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Headline
                    CustomText(
                      text: "Unlock Your Full\nAi Fitness Experience",
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    CustomText(
                      text:
                          "Get personalized plans, expert guidance\nand real results.",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 18.h),

                    // White card — features + plan
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _featureIconsRow(),
                          SizedBox(height: 20.h),

                          // Annual plan only
                          Obx(() => _planCard()),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            // ── CTA button + terms ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
              child: Column(
                children: [
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: controller.purchaseLoading.value
                            ? null
                            : () => controller.upgradeNow(),
                        child: controller.purchaseLoading.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : CustomText(
                                text: "Start 3-Day Free Trial",
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Obx(() => controller.purchaseError.value.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: CustomText(
                            text: controller.purchaseError.value,
                            fontSize: 12.sp,
                            color: AppColors.error,
                            textAlign: TextAlign.center,
                            maxline: 3,
                          ),
                        )
                      : const SizedBox.shrink()),
                  CustomText(
                    text: "Cancel anytime  •  No hidden fees",
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "By continuing, you agree to our ",
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(
                          Uri.parse(ApiUrls.termsOfService),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: CustomText(
                          text: "Terms of Service",
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Already a member? ─────────────────────────────────────
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            _alreadyMemberSection(),
          ],
        ),
      ),
    );
  }

  // ── Feature icons ─────────────────────────────────────────────────────────

  Widget _featureIconsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _featureIcon(Icons.fitness_center, "AI Personal\nTrainer",
            "Coaching that\nadapts to you"),
        _featureIcon(Icons.assignment_turned_in_outlined, "Smart\nWorkouts",
            "Plans built for\nyour goals"),
        _featureIcon(Icons.insights_outlined, "Track\nProgress",
            "See results and\nstay motivated"),
        _featureIcon(Icons.stadium_outlined, "Gyms &\nCommunity",
            "Access gyms and\nconnect"),
      ],
    );
  }

  Widget _featureIcon(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEFE0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22.sp),
          ),
          SizedBox(height: 6.h),
          CustomText(
            text: title,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          CustomText(
            text: subtitle,
            fontSize: 9.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
            maxline: 2,
          ),
        ],
      ),
    );
  }

  // ── Annual plan card ──────────────────────────────────────────────────────

  Widget _planCard() {
    final discounted = controller.hasPromo;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            Icons.radio_button_checked,
            color: AppColors.primary,
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "Annual Plan",
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  text: "Billed once a year",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: discounted
                    ? "\$${controller.annualPrice.toStringAsFixed(2)}"
                    : controller.annualPriceStr.value,
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
              if (discounted)
                CustomText(
                  text: "50% off applied",
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                )
              else
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomText(
                    text: "Save 50%",
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Admin bypass (hidden — triggered programmatically if needed) ──────────

  void _showAdminBypassSheet(BuildContext context) {
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
                  Icon(Icons.shield_outlined,
                      color: AppColors.primary, size: 20.sp),
                  SizedBox(width: 8.w),
                  CustomText(
                    text: 'Admin Access',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close,
                        size: 20.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              CustomText(
                text: 'Enter your admin PIN to unlock full access.',
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                obscureText: true,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22.sp, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '• • • •',
                  hintStyle: TextStyle(
                      fontSize: 18.sp,
                      letterSpacing: 6,
                      color: Colors.grey.shade400),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 16.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        const BorderSide(color: Color(0xFFD9D9D9)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        const BorderSide(color: AppColors.primary),
                  ),
                ),
                onSubmitted: (_) async {
                  await _activateAdminCode(codeController, loading, error);
                },
              ),
              Obx(() => error.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: CustomText(
                        text: error.value,
                        fontSize: 12.sp,
                        color: AppColors.error,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink()),
              SizedBox(height: 16.h),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: loading.value
                          ? null
                          : () async {
                              await _activateAdminCode(
                                  codeController, loading, error);
                            },
                      child: loading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : CustomText(
                              text: 'Activate Admin',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textWhite,
                            ),
                    ),
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _activateAdminCode(
    TextEditingController codeController,
    RxBool loading,
    RxString error,
  ) async {
    final code = codeController.text.trim();
    if (code.isEmpty) {
      error.value = 'Please enter your PIN';
      return;
    }
    loading.value = true;
    error.value = '';
    try {
      final resp = await ApiClient.postData(
        ApiUrls.baseUrl + ApiUrls.adminBypass,
        {'code': code},
      );
      loading.value = false;
      if (resp.statusCode == 200) {
        Get.back();
        Get.snackbar(
          '🔓 Admin Access Activated',
          'Full access unlocked. Enjoy the app.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade800,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        Get.offAll(() => NavBar());
      } else {
        error.value = 'Invalid PIN. Try again.';
      }
    } catch (_) {
      loading.value = false;
      error.value = 'Connection error. Try again.';
    }
  }

  // ── Already a member? ─────────────────────────────────────────────────────

  Widget _alreadyMemberSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDEFE0),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline,
                    color: AppColors.primary, size: 22.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: "Already a member?",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 2.h),
                    CustomText(
                      text:
                          "Enter your access code to continue to the app.",
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      maxline: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.accessCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: "Enter your access code",
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 13.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFDDDDDD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Obx(
                () => SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                    ),
                    onPressed: controller.accessCodeLoading.value
                        ? null
                        : controller.redeemAccessCode,
                    child: controller.accessCodeLoading.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : CustomText(
                            text: "Continue",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textWhite,
                          ),
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => controller.accessCodeError.value.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: CustomText(
                      text: controller.accessCodeError.value,
                      fontSize: 12.sp,
                      color: AppColors.error,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
