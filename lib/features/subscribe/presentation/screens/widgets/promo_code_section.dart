import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PromoCodeSection extends StatelessWidget {
  const PromoCodeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SubscribeController.to;

    return Obx(() {
      if (controller.isPromoApplied) {
        return _AppliedPromoCard(
          code: controller.appliedPromoCode,
          onRemove: controller.removePromoCode,
        );
      }

      return CustomContainer(
        onTap: () => Get.toNamed(AppRoute.promoCodeScreen),
        width: double.infinity,
        paddingHorizontal: 16.w,
        paddingVertical: 14.h,
        radiusAll: 16.r,
        color: Colors.white,
        bordersColor: AppColors.secondary,
        child: Row(
          children: [
            CustomContainer(
              width: 40.w,
              height: 40.w,
              radiusAll: 12.r,
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.local_offer_outlined,
                size: 20.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Have a promo code?',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.start,
                  ),
                  CustomText(
                    text: 'Tap to apply discount',
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: AppColors.primary,
            ),
          ],
        ),
      );
    });
  }
}

class _AppliedPromoCard extends StatelessWidget {
  const _AppliedPromoCard({
    required this.code,
    required this.onRemove,
  });

  final String code;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      width: double.infinity,
      paddingHorizontal: 16.w,
      paddingVertical: 14.h,
      radiusAll: 16.r,
      color: AppColors.primary.withValues(alpha: 0.08),
      bordersColor: AppColors.primary.withValues(alpha: 0.3),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 22.sp,
            color: AppColors.primary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Promo code applied',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.start,
                ),
                CustomText(
                  text: code,
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: CustomText(
              text: 'Remove',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
