import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/features/paywall/controllers/paywall_controller.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';

class PaywallScreen extends StatelessWidget {
  PaywallScreen({super.key});

  final controller = Get.find<PaywallController>();

  @override
  Widget build(BuildContext context) {
    // Default to 3-month plan on first open
    if (controller.selectedPlan.value == "annual") {
      controller.selectedPlan.value = "monthly";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.h),

                    // Logo — multiply blend removes the white square background
                    Image.asset(
                      'assets/images/app_logo.png',
                      height: 80.h,
                      color: Colors.white,
                      colorBlendMode: BlendMode.multiply,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.fitness_center,
                        size: 56.sp,
                        color: AppColors.primary,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Headline
                    CustomText(
                      text: "Unlock Your Full\nAi Fitness Experience",
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 6.h),

                    CustomText(
                      text:
                          "Get personalized plans, expert guidance\nand real results.",
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20.h),

                    // Feature icons
                    _featureIconsRow(),

                    SizedBox(height: 20.h),

                    // ── 3 Month Plan (default selected) ───────────
                    Obx(() => _threeMonthCard()),

                    SizedBox(height: 10.h),

                    // ── Annual Plan ───────────────────────────────
                    Obx(() => _annualCard()),

                    SizedBox(height: 24.h),

                    // ── CTA Button ────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Get.offAllNamed(AppRoute.signUpScreen),
                        child: CustomText(
                          text: "Start 7-Day Free Trial",
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

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

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            // ── Already a member (pinned at bottom) ───────────────
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            _alreadyMemberSection(),
          ],
        ),
      ),
    );
  }

  // ── Feature icons ──────────────────────────────────────────────────────────

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
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEFE0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(height: 5.h),
          CustomText(
            text: title,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
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

  // ── 3 Month Plan card ──────────────────────────────────────────────────────

  Widget _threeMonthCard() {
    final selected = controller.selectedPlan.value == "monthly";
    return GestureDetector(
      onTap: () => controller.selectPlan("monthly"),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFDDDDDD),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppColors.primary : const Color(0xFFBBBBBB),
                size: 22.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "3 Month Plan",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 1.h),
                  CustomText(
                    text: "7-Day Free Trial",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  CustomText(
                    text: "\$19.99 for 3 months after trial",
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: "\$19.99",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
                SizedBox(height: 3.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomText(
                    text: "7-Day Free Trial",
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: "\$6.65/mo",
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Annual Plan card ───────────────────────────────────────────────────────

  Widget _annualCard() {
    final selected = controller.selectedPlan.value == "annual";
    return GestureDetector(
      onTap: () => controller.selectPlan("annual"),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFDDDDDD),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppColors.primary : const Color(0xFFBBBBBB),
                size: 22.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Annual Plan",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 1.h),
                  CustomText(
                    text: "Billed once a year",
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: "\$49.99",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
                SizedBox(height: 3.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomText(
                    text: "Save 50%",
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: "vs \$19.99/mo",
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Already a member ───────────────────────────────────────────────────────

  Widget _alreadyMemberSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDEFE0),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline,
                    color: AppColors.primary, size: 20.sp),
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
                      text: "Enter your access code to continue to the app.",
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      maxline: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.accessCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: "Enter your access code",
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 12.h),
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
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 18.w),
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
