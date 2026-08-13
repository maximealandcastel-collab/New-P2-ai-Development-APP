import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/features/paywall/controllers/paywall_controller.dart';
import 'package:pler_to_pler_app/features/nav_bar/presentation/screens/nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';

class PaywallScreen extends StatelessWidget {
  PaywallScreen({super.key});

  final controller = Get.find<PaywallController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F2),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Close button ─────────────────────────────────────
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

              SizedBox(height: 6.h),

              // ── Logo ─────────────────────────────────────────────
              Image.asset(
                'assets/images/app_logo.png',
                height: 80.h,
                errorBuilder: (context, error, stack) => Icon(
                  Icons.fitness_center,
                  size: 60.sp,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(height: 10.h),

              // ── Headline ─────────────────────────────────────────
              CustomText(
                text: "Unlock Your Full\nAi Fitness Experience",
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 6.h),

              CustomText(
                text: "Get personalized plans, expert guidance\nand real results.",
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 14.h),

              // ── White card — features + plan ─────────────────────
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _featureIconsRow(),
                    SizedBox(height: 16.h),
                    Obx(() => _planCard()),
                  ],
                ),
              ),

              const Spacer(),

              // ── CTA button ───────────────────────────────────────
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
                        : () => Get.offAll(() => NavBar()),
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
                            text: "Start 7-Day Free Trial",
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textWhite,
                          ),
                  ),
                ),
              ),

              SizedBox(height: 6.h),

              // ── Cancel / terms ───────────────────────────────────
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

  // ── Annual plan card ───────────────────────────────────────────────────────

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
                  fontSize: 17.sp,
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
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
              ),
              SizedBox(height: 2.h),
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
    );
  }
}
