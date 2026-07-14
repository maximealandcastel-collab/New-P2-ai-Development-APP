import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/plan_model.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/payment_details_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/subscribe_card.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentDetailsController());
    return CustomScaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
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

                      // ── Plan Cards ──────────────────────────────────────
                      Obx(() {
                        final iapState = controller.iapLoadingState;

                        if (iapState == LoadingState.loading) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: PlanModel.plans.length,
                          itemBuilder: (context, index) {
                            // Merge store price when available
                            final iapProducts = controller.products;
                            final plan = PlanModel.plans[index];
                            final productId =
                                index == 0 ? kProductAnnual : kProductMonthly;

                            ProductDetails? storeProduct;
                            try {
                              storeProduct = iapProducts.firstWhere(
                                (p) => p.id == productId,
                              );
                            } catch (_) {
                              storeProduct = null;
                            }

                            final displayPlan =
                                storeProduct != null
                                    ? plan.copyWithStorePrice(
                                      storeProduct.price,
                                    )
                                    : plan;

                            return Obx(
                              () => SubscribeCard(
                                plan: displayPlan,
                                isSelected: controller.selectedIndex == index,
                                onTap: () => controller.onChange(index),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Upgrade Button ────────────────────────────────────────
                Obx(() {
                  final isBuying = controller.isPurchasing;
                  final iapAvailable = controller.iapAvailable;
                  final iapLoaded =
                      controller.iapLoadingState == LoadingState.loaded;

                  return CustomButton(
                    onPressed:
                        (isBuying || !iapAvailable || !iapLoaded)
                            ? null
                            : () => controller.buySelectedPlan(),
                    label: isBuying ? 'Processing...' : 'Upgrade Now',
                    child:
                        isBuying
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18.w,
                                  height: 18.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                CustomText(
                                  text: 'Processing...',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            )
                            : null,
                  );
                }),

                SizedBox(height: 16.h),
                CustomText(
                  text: 'Cancel anytime • No hidden fees',
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),

                // ── IAP not available fallback ────────────────────────────
                Obx(() {
                  if (controller.iapLoadingState == LoadingState.error) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: CustomText(
                        text:
                            'In-app purchase unavailable.\nPlease try again later.',
                        fontSize: 12.sp,
                        color: AppColors.error,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                SizedBox(height: 20.h),
              ],
            ),
          ),

          // ── Close Button ────────────────────────────────────────────────
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
    );
  }
}
