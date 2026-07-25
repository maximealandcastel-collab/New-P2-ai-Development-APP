import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/core/utils/constants/image_path.dart';
import 'package:p2p_fitness/features/paywall/controllers/paywall_controller.dart';

class PaywallScreen extends StatelessWidget {
  PaywallScreen({super.key});

  final controller = Get.put(PaywallController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
                child: Column(
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          margin: EdgeInsets.only(top: getHeight(8)),
                          padding: EdgeInsets.all(getWidth(8)),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close,
                              size: 20.sp, color: AppColors.textPrimary),
                        ),
                      ),
                    ),

                    // Logo
                    Image.asset(
                      ImagePath.appLogo,
                      height: getHeight(110),
                      errorBuilder: (context, error, stack) => Icon(
                        Icons.fitness_center,
                        size: 64.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: getHeight(16)),

                    // Headline
                    CustomText(
                      text: "Unlock Your Full\nAi Fitness Experience",
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: getHeight(10)),
                    CustomText(
                      text:
                          "Get personalized plans, expert guidance\nand real results.",
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: getHeight(20)),

                    // White card with features + plans + promo
                    Container(
                      padding: EdgeInsets.all(getWidth(16)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _featureIconsRow(),
                          SizedBox(height: getHeight(20)),

                          // Annual plan
                          Obx(
                            () => _planCard(
                              planKey: "annual",
                              title: "Annual Plan",
                              subtitle: "Billed once a year",
                              price: controller.annualPrice,
                              badge: "Save 50%",
                              mostPopular: true,
                              bullets: const [
                                "Everything in monthly",
                                "AI-guided plans & workouts",
                                "Track progress & analytics",
                                "Access to all core features",
                              ],
                            ),
                          ),
                          SizedBox(height: getHeight(12)),

                          // Monthly plan
                          Obx(
                            () => _planCard(
                              planKey: "monthly",
                              title: "Monthly Plan",
                              subtitle: "Billed every month",
                              price: controller.monthlyPrice,
                              badge: null,
                              mostPopular: false,
                              bullets: const [
                                "AI-guided plans & workouts",
                                "Track progress & analytics",
                                "Access to all core features",
                              ],
                            ),
                          ),
                          SizedBox(height: getHeight(16)),

                          _promoCodeSection(),
                        ],
                      ),
                    ),
                    SizedBox(height: getHeight(16)),

                    // Trust badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _trustBadge(Icons.lock_outline, "Secure Payment"),
                        _trustBadge(Icons.shield_outlined, "Cancel Anytime"),
                        _trustBadge(Icons.headset_mic_outlined, "24/7 Support"),
                      ],
                    ),
                    SizedBox(height: getHeight(12)),
                  ],
                ),
              ),
            ),

            // Upgrade button + terms
            Padding(
              padding: EdgeInsets.fromLTRB(
                  getWidth(16), getHeight(4), getWidth(16), getHeight(12)),
              child: Column(
                children: [
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: getHeight(54),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: controller.checkoutLoading.value
                            ? null
                            : () async {
                                final url = await controller.upgradeNow();
                                if (url != null) {
                                  // TODO: open [url] in the browser / webview
                                  // (e.g. url_launcher: launchUrl(Uri.parse(url),
                                  // mode: LaunchMode.externalApplication)).
                                  log("Open Stripe checkout: $url");
                                }
                              },
                        child: controller.checkoutLoading.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : CustomText(
                                text: "Upgrade Now",
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                textColor: AppColors.textWhite,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "By continuing, you agree to our ",
                        fontSize: 12.sp,
                        textColor: AppColors.textSecondary,
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: open terms of service page
                        },
                        child: CustomText(
                          text: "Terms of Service",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Widgets ----------------

  Widget _featureIconsRow() {
    return Row(
      children: [
        _featureIcon(Icons.fitness_center, "AI Personal\nTrainer",
            "Coaching that adapts to you"),
        _divider(),
        _featureIcon(Icons.assignment_turned_in_outlined, "Smart\nWorkouts",
            "Plans built for your goals"),
        _divider(),
        _featureIcon(Icons.insights_outlined, "Track\nProgress",
            "See results and stay motivated"),
        _divider(),
        _featureIcon(Icons.stadium_outlined, "Gyms &\nCommunity",
            "Access gyms and connect"),
      ],
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: getHeight(70),
        color: const Color(0xFFEDEDED),
      );

  Widget _featureIcon(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(getWidth(10)),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEFE0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22.sp),
          ),
          SizedBox(height: getHeight(6)),
          CustomText(
            text: title,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: getHeight(2)),
          CustomText(
            text: subtitle,
            fontSize: 9.sp,
            textColor: AppColors.textSecondary,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required String planKey,
    required String title,
    required String subtitle,
    required double price,
    required List<String> bullets,
    String? badge,
    bool mostPopular = false,
  }) {
    final selected = controller.selectedPlan.value == planKey;
    final discounted = controller.hasPromo;

    return GestureDetector(
      onTap: () => controller.selectPlan(planKey),
      child: Container(
        padding: EdgeInsets.all(getWidth(14)),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF8F1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE5E5E5),
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? AppColors.primary
                      : const Color(0xFFBDBDBD),
                  size: 22.sp,
                ),
                SizedBox(width: getWidth(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: title,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      CustomText(
                        text: subtitle,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: "\$${price.toStringAsFixed(2)}",
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    if (discounted)
                      CustomText(
                        text: "50% off applied",
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.success,
                      )
                    else if (badge != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: getWidth(8), vertical: getHeight(3)),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomText(
                          text: badge,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.textWhite,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: getHeight(10)),
            ...bullets.map(
              (b) => Padding(
                padding: EdgeInsets.only(bottom: getHeight(5)),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.primary, size: 16.sp),
                    SizedBox(width: getWidth(6)),
                    Expanded(
                      child: CustomText(
                        text: b,
                        fontSize: 12.sp,
                        textColor: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (mostPopular) ...[
              SizedBox(height: getHeight(6)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: getWidth(12), vertical: getHeight(8)),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9E3CC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: AppColors.primary, size: 16.sp),
                    SizedBox(width: getWidth(6)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Most Popular",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        CustomText(
                          text: "Great for getting started",
                          fontSize: 10.sp,
                          textColor: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _promoCodeSection() {
    return Obx(() {
      // Applied state — green chip with remove option
      if (controller.hasPromo) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: getWidth(12), vertical: getHeight(10)),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7EC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 18.sp),
              SizedBox(width: getWidth(8)),
              Expanded(
                child: CustomText(
                  text:
                      "Code applied: ${controller.appliedPromoCode.value}",
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: controller.removePromoCode,
                child: Icon(Icons.close,
                    size: 18.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          GestureDetector(
            onTap: controller.togglePromoField,
            child: CustomText(
              text: "Have a promo code?",
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              textColor: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
          if (controller.showPromoField.value) ...[
            SizedBox(height: getHeight(10)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: "Enter promo code",
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: getWidth(12), vertical: getHeight(12)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.textFormFieldBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: getWidth(8)),
                SizedBox(
                  height: getHeight(46),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.promoLoading.value
                        ? null
                        : controller.applyPromoCode,
                    child: controller.promoLoading.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : CustomText(
                            text: "Apply",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            textColor: AppColors.textWhite,
                          ),
                  ),
                ),
              ],
            ),
          ],
          if (controller.promoError.value.isNotEmpty) ...[
            SizedBox(height: getHeight(6)),
            CustomText(
              text: controller.promoError.value,
              fontSize: 12.sp,
              textColor: AppColors.error,
            ),
          ],
        ],
      );
    });
  }

  Widget _trustBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textSecondary),
        SizedBox(width: getWidth(4)),
        CustomText(
          text: label,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          textColor: AppColors.textSecondary,
        ),
      ],
    );
  }
}
