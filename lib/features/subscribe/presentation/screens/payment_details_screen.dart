import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/plan_model.dart';
import 'package:pler_to_pler_app/features/subscribe/domain/services/subscribe_services.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/payment_details_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/subscribe_card.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

/// Terms / Privacy link for the paywall. Opens the existing legal screen,
/// which reads its document from the `key` argument.
class _LegalLink extends StatelessWidget {
  final String label;
  final String docKey;
  final String title;

  const _LegalLink({
    required this.label,
    required this.docKey,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoute.privacyPolicyScreen,
        arguments: {'title': title, 'key': docKey, 'consent': false},
      ),
      child: CustomText(
        text: label,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      PaymentDetailsController(
        subscribeService: Get.find<SubscribeServices>(),
        profileService: Get.find<ProfileService>(),
      ),
    );
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && Get.isRegistered<PaymentDetailsController>()) {
          Get.delete<PaymentDetailsController>();
        }
      },
      child: CustomScaffold(
        body: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.backgroundLight,
              onRefresh: controller.refreshProducts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 60.h),
                    Center(child: Assets.images.logo.image(height: 110.h)),
                    CustomText(
                      top: 10.h,
                      text: 'Unlock Your Full\nAi Fitness Experience',
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    CustomText(
                      top: 10.h,
                      bottom: 20.h,
                      text:
                          'Get personalized plans, expert guidance\nand real results.',
                    ),
                    CustomContainer(
                      paddingAll: 16.r,
                      radiusAll: 20.r,
                      width: double.infinity,
                      color: Colors.white,
                      child: Column(
                        children: [
                          Assets.icons.subscribeIcons.svg(),
                          SizedBox(height: 20.h),

                          // ── Plan Cards ──────────────────────────────────
                          Obx(() {
                            final iapProducts = controller.products;
                            final selectedIndex = controller.selectedIndex;

                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: PlanModel.plans.length,
                              itemBuilder: (context, index) {
                                // Merge store price when available
                                final plan = PlanModel.plans[index];
                                final productId = index == 0
                                    ? kProductAnnual
                                    : kProductMonthly;

                                ProductDetails? storeProduct;
                                try {
                                  storeProduct = iapProducts.firstWhere(
                                    (p) => p.id == productId,
                                  );
                                } catch (_) {
                                  storeProduct = null;
                                }

                                final displayPlan = storeProduct != null
                                    ? plan.copyWithStorePrice(
                                        storeProduct.price,
                                      )
                                    : plan;

                                return SubscribeCard(
                                  plan: displayPlan,
                                  isSelected: selectedIndex == index,
                                  onTap: () => controller.onChange(index),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ── Upgrade Button ────────────────────────────────────
                    Obx(() {
                      final isBuying =
                          controller.purchaseLoadingState.isLoading;
                      final isLoadingProducts =
                          controller.iapLoadingState.isLoading;
                      final canPurchase = controller.canPurchase;

                      return CustomButton(
                        onPressed: canPurchase
                            ? () => controller.buySelectedPlan()
                            : null,
                        isLoading: isBuying || isLoadingProducts,
                        label: 'Upgrade Now',
                      );
                    }),

                    SizedBox(height: 16.h),
                    CustomText(
                      text: 'Cancel anytime • No hidden fees',
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),

                    // ── Restore + legal links ─────────────────────────────
                    // Required by App Store Review: 3.1.1 (a restore path for
                    // auto-renewable subscriptions) and 3.1.2 (Terms of Use and
                    // Privacy Policy reachable from the purchase screen).
                    SizedBox(height: 12.h),
                    Obx(() {
                      final busy = controller.purchaseLoadingState.isLoading;
                      return TextButton(
                        onPressed:
                            busy ? null : () => controller.restorePurchases(),
                        child: CustomText(
                          text: 'Restore Purchases',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      );
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegalLink(
                          label: 'Terms of Use',
                          docKey: 'terms',
                          title: 'Terms of Service',
                        ),
                        CustomText(
                          text: '  •  ',
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                        _LegalLink(
                          label: 'Privacy Policy',
                          docKey: 'privacy',
                          title: 'Privacy Policy',
                        ),
                      ],
                    ),

                    // ── IAP not available fallback ────────────────────────
                    Obx(() {
                      if (!controller.iapLoadingState.isError) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: CustomText(
                          text:
                              'Products unavailable right now.\nPull down to refresh and try again.',
                          fontSize: 12.sp,
                          color: AppColors.error,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // ── Close Button ──────────────────────────────────────────────
            Positioned(
              top: 6.h,
              right: 0,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CustomContainer(
                    shape: BoxShape.circle,
                    paddingAll: 8.r,
                    color: Colors.white,
                    child: Assets.icons.clean.svg(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
