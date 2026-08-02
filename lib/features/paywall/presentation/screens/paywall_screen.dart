import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/constants/image_path.dart';
import 'package:pler_to_pler_app/features/paywall/controllers/paywall_controller.dart';
import 'package:pler_to_pler_app/features/nav_bar/presentation/screens/nav_bar.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/dio_api_client.dart';
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

                    // Logo
                    Image.asset(
                      ImagePath.appLogo,
                      height: 110.h,
                      errorBuilder: (context, error, stack) => Icon(
                        Icons.fitness_center,
                        size: 64.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Headline
                    CustomText(
                      text: "Unlock Your Full\nAi Fitness Experience",
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    CustomText(
                      text:
                          "Get personalized plans, expert guidance\nand real results.",
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),

                    // White card with features + plans + promo
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
                          SizedBox(height: 12.h),

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
                          SizedBox(height: 16.h),

                          _promoCodeSection(),
                          SizedBox(height: 12.h),
                          GestureDetector(
                            onTap: () => _showAdminBypassSheet(context),
                            child: CustomText(
                              text: 'Activate Admin Access',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              textAlign: TextAlign.center,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Trust badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _trustBadge(Icons.lock_outline, "Secure Payment"),
                        _trustBadge(Icons.shield_outlined, "Cancel Anytime"),
                        _trustBadge(Icons.headset_mic_outlined, "24/7 Support"),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),

            // Upgrade button + terms
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16.w, 4.h, 16.w, 12.h),
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
                                text: "Upgrade Now",
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Purchase error message
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "By continuing, you agree to our ",
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(
                          Uri.parse(ApiUrls.termsOfService),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: CustomText(
                          text: "Terms of Service",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
        height: 70.h,
        color: const Color(0xFFEDEDED),
      );

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
        padding: EdgeInsets.all(14.w),
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
                SizedBox(width: 8.w),
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
                        color: AppColors.textSecondary,
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
                        color: AppColors.success,
                      )
                    else if (badge != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomText(
                          text: badge,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textWhite,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ...bullets.map(
              (b) => Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.primary, size: 16.sp),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: CustomText(
                        text: b,
                        fontSize: 12.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (mostPopular) ...[
              SizedBox(height: 6.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9E3CC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: AppColors.primary, size: 16.sp),
                    SizedBox(width: 6.w),
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
                          color: AppColors.textSecondary,
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
              horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7EC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 18.sp),
              SizedBox(width: 8.w),
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
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
          if (controller.showPromoField.value) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: "Enter promo code",
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 12.h),
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
                SizedBox(width: 8.w),
                SizedBox(
                  height: 46.h,
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
                            color: AppColors.textWhite,
                          ),
                  ),
                ),
              ],
            ),
          ],
          if (controller.promoError.value.isNotEmpty) ...[
            SizedBox(height: 6.h),
            CustomText(
              text: controller.promoError.value,
              fontSize: 12.sp,
              color: AppColors.error,
            ),
          ],
        ],
      );
    });
  }

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
              // drag handle
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
                  Icon(Icons.shield_outlined, color: AppColors.primary, size: 20.sp),
                  SizedBox(width: 8.w),
                  CustomText(
                    text: 'Admin Access',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close, size: 20.sp, color: AppColors.textSecondary),
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
                  hintStyle: TextStyle(fontSize: 18.sp, letterSpacing: 6, color: Colors.grey.shade400),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.textFormFieldBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.primary),
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
                              await _activateAdminCode(codeController, loading, error);
                            },
                      child: loading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
      final resp = await NetworkCaller.instance.postRequest(
        url: ApiUrls.baseUrl + ApiUrls.adminBypass,
        body: {'code': code},
      );
      loading.value = false;
      if (resp.isSuccess) {
        Get.back(); // close sheet
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

  Widget _trustBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textSecondary),
        SizedBox(width: 4.w),
        CustomText(
          text: label,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
