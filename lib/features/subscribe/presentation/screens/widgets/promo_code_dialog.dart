import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PromoCodeDialog extends StatelessWidget {
  const PromoCodeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SubscribeController.to;

    return Dialog(
      backgroundColor: AppColors.backgroundLight,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomContainer(
              width: 64.w,
              height: 64.w,
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
              child: Icon(
                Icons.local_offer_rounded,
                size: 30.sp,
                color: AppColors.primary,
              ),
            ),
            CustomText(
              top: 16.h,
              text: 'Have a promo code?',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            CustomText(
              top: 8.h,
              text: 'Enter your code to unlock a discount,\nor skip to continue.',
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            CustomTextField(
              controller: controller.promoCodeController,
              hintText: 'e.g. P2PW-CLWB-0101',
              textInputAction: TextInputAction.done,
              validator: (_) => null,
            ),
            SizedBox(height: 20.h),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      height: 46.h,
                      fontSize: 14.sp,
                      label: 'Skip',
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.primary,
                      bordersColor: AppColors.primary,
                      borderWidth: 1,
                      onPressed: controller.isCheckingOut
                          ? null
                          : () => controller.createDefaultCheckout(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      height: 46.h,
                      fontSize: 14.sp,
                      label: 'Continue',
                      isLoading: controller.isCheckingOut,
                      onPressed: () => controller.createDefaultCheckout(
                        promoCode: controller.promoCodeController.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
