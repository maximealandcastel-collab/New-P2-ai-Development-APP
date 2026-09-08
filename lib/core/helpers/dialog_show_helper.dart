import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DialogShowHelper {
  DialogShowHelper._();

  static Widget showBottomSheet(
      BuildContext context, {
        Widget? content,
        required String title,
        String? buttonLabel,
        VoidCallback? onTapConfirm,
        bool isLoading = false,
      })  {
    return CustomContainer(
      paddingAll: 16.r,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomContainer(
                  color: AppColors.textPrimary,
                  width: 40.w,
                  height: 4.h,
                  radiusAll: 99.r,
                  marginBottom: 6.h,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 32.w),
                    CustomText(
                      text: title,
                      fontSize: 20.sp,
                      fontWeight: AppFontWeight.section,
                    ),
                    CustomContainer(
                      onTap: isLoading ? null : () => Get.back(canPop: true),
                      shape: BoxShape.circle,
                      color: AppColors.colorE6E6E6,
                      paddingAll: 10.r,
                      child: Assets.icons.clean.svg(height: 20.h, width: 20.w),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ?content,
                SizedBox(height: 24.h),
                CustomButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    onTapConfirm?.call();
                    //Get.back(canPop: true);
                  },
                  label: buttonLabel ?? 'Continue',
                ),
              ],
            ),

            if (isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 2.5,
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
