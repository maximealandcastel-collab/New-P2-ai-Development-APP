import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/features/paywall/controllers/paywall_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';

class PaywallScreen extends StatelessWidget {
  PaywallScreen({super.key});

  final controller = Get.find<PaywallController>();
  final RxInt selectedTier = 1.obs; // 0=Self-Guided, 1=Personal Trainer, 2=Elite Coaching

  @override
  Widget build(BuildContext context) {
    controller.configureDestination(Get.arguments);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: controller.continueSelfGuided,
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(Icons.chevron_left, color: Colors.black, size: 22.sp),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 26.h,
                        width: 26.h,
                        child: ClipOval(
                          child: Transform.scale(
                            scale: 1.12,
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.fitness_center,
                                color: AppColors.primary,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 7.w),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: "P2P "),
                                TextSpan(
                                  text: "FIT",
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            "TECH AI",
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 1.0,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    "Admin",
                    style: TextStyle(color: Colors.black54, fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // ── Scrollable Content ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    Text(
                      "Matched in under 2 minutes",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "A coach who trains\nyou, not a template..",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Get paired with a certified trainer plus an AI that adjusts your plan every week based on how you actually perform.",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700, height: 1.4),
                    ),
                    SizedBox(height: 24.h),

                    // Stats Row
                    Row(
                      children: [
                        Expanded(child: _buildStatBox("4.9", "Avg. trainer\nrating")),
                        SizedBox(width: 8.w),
                        Expanded(child: _buildStatBox("92%", "Hit their 90-day\ngoal")),
                        SizedBox(width: 8.w),
                        Expanded(child: _buildStatBox("<2hr", "Trainer response\ntime")),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Toggle
                    _buildToggle(),
                    SizedBox(height: 24.h),

                    // Tiers
                    Obx(() {
                      final isAnnual = controller.selectedPlan.value == 'annual';
                      final ptPrice = isAnnual ? "${controller.annualPriceStr.value}/yr" : "${controller.monthlyPriceStr.value}/mo";
                      final ecPrice = isAnnual ? "\$449.99/yr" : "\$49.99/mo";

                      return Column(
                        children: [
                          _buildTierCard(
                            index: 0,
                            title: "Self-Guided",
                            price: "\$0",
                            desc: "AI workouts and tracking, no dedicated coach.",
                          ),
                          _buildTierCard(
                            index: 1,
                            title: "Personal Trainer",
                            price: ptPrice,
                            desc: "1-on-1 coaching, weekly check-ins, plans built for you.",
                            badge: "Most chosen",
                          ),
                          _buildTierCard(
                            index: 2,
                            title: "Elite Coaching",
                            price: ecPrice,
                            desc: "Everything in Trainer plus nutrition coaching.",
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 8.h),

                    // CTA & Terms
                    _buildCTA(),
                    SizedBox(height: 32.h),

                    // P2P Code Box
                    _buildP2PCodeBox(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 4.h),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600, height: 1.2)),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Obx(() {
      final isAnnual = controller.selectedPlan.value == 'annual';
      return Container(
        height: 48.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectPlan('monthly'),
                child: Container(
                  decoration: BoxDecoration(
                    color: !isAnnual ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: !isAnnual ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
                  ),
                  alignment: Alignment.center,
                  child: Text("Monthly", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: !isAnnual ? Colors.black : Colors.grey.shade600)),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectPlan('annual'),
                child: Container(
                  decoration: BoxDecoration(
                    color: isAnnual ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isAnnual ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Annual", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: isAnnual ? Colors.black : Colors.grey.shade600)),
                      SizedBox(width: 4.w),
                      Text("Save 25%", style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTierCard({
    required int index,
    required String title,
    required String price,
    required String desc,
    String? badge,
  }) {
    return Obx(() {
      final isSelected = selectedTier.value == index;
      return GestureDetector(
        onTap: () => selectedTier.value = index,
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 2.h, right: 12.w),
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(price, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(desc, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600, height: 1.3)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Positioned(
                  top: -10.h,
                  left: 32.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    color: Colors.white,
                    child: Text(
                      badge,
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCTA() {
    return Obx(() {
      final tier = selectedTier.value;
      final isAnnual = controller.selectedPlan.value == 'annual';
      final ptPrice = isAnnual ? "${controller.annualPriceStr.value}/yr" : "${controller.monthlyPriceStr.value}/mo";
      final ecPrice = isAnnual ? "\$449.99/yr" : "\$49.99/mo";

      String ctaText = "";
      if (tier == 0) {
        ctaText = "Continue with Self-Guided — \$0";
      } else if (tier == 1) {
        ctaText = "Start with Personal Trainer — $ptPrice";
      } else {
        ctaText = "Start Elite Coaching — $ecPrice";
      }

      return Column(
        children: [
          if (controller.purchaseError.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                controller.purchaseError.value,
                style: TextStyle(fontSize: 13.sp, color: AppColors.error, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tier == 2 ? Colors.black : AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              onPressed: controller.purchaseLoading.value
                  ? null
                  : () {
                      if (tier == 0) {
                        controller.continueSelfGuided();
                      } else if (tier == 1) {
                        controller.upgradeNow();
                      } else {
                        Get.snackbar("Coming Soon", "Elite Coaching is not yet available.", snackPosition: SnackPosition.BOTTOM);
                      }
                    },
              child: controller.purchaseLoading.value && tier == 1
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      ctaText,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "Billed ${isAnnual ? 'annually' : 'monthly'} · cancel anytime",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("By continuing, you agree to our ", style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
              GestureDetector(
                onTap: () async {
                  final opened = await launchUrl(
                    Uri.parse(ApiUrls.termsOfService),
                    mode: LaunchMode.externalApplication,
                  );
                  if (!opened) {
                    Get.snackbar(
                      'Unable to open link',
                      'Please try again in a moment.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: Text(
                  "Terms of Service",
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildP2PCodeBox() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vpn_key_outlined, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text("P2P Code", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          SizedBox(height: 6.h),
          Text("For customers who already have an access code.", style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: TextField(
                    controller: controller.accessCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: "Enter code",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Obx(() => SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                      ),
                      onPressed: controller.accessCodeLoading.value ? null : controller.redeemAccessCode,
                      child: controller.accessCodeLoading.value
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("Redeem", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    ),
                  )),
            ],
          ),
          Obx(() => controller.accessCodeError.value.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(controller.accessCodeError.value, style: TextStyle(color: AppColors.error, fontSize: 12.sp)),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
