import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String?  description;
  final String? leftButtonLabel;
  final String? rightButtonLabel;
  final Color? rightButtonBgColor, rightButtonLabelColor;
  final Color? leftButtonBgColor, leftButtonLabelColor;
  final Color? titleColor;
  final Widget? content;
  final VoidCallback onTapLeftButton;
  final VoidCallback onTapRightButton;
  final bool isLoading;

  const CustomDialog({
    super.key,
    required this.title,
    this.leftButtonLabel = "Cancel",
    this.rightButtonLabel = "Log Out",
    required this.onTapLeftButton,
    required this.onTapRightButton,
    this.rightButtonBgColor = AppColors.error,
    this.rightButtonLabelColor = Colors.white,
    this.leftButtonBgColor = Colors.transparent,
    this.leftButtonLabelColor = AppColors.primary,
    this.description,
    this.content,
    this.titleColor = AppColors.error,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundLight,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Text
                CustomText(text: title, fontSize: 16.sp, color: titleColor),
                SizedBox(height: 6.h),

                Divider(color: AppColors.secondary, thickness: 0.5.h),

                SizedBox(height: 6.h),

                // Description Text
                if(description != null)
                CustomText(
                  left: 10.w,
                  right: 10.w,
                  text: description!,
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                  maxline: 2,
                ),
                ?content,
                SizedBox(height: 32.h),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    Expanded(
                      child: CustomButton(
                        height: 38.h,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        bordersColor: leftButtonLabelColor,
                        backgroundColor: leftButtonBgColor,
                        foregroundColor: leftButtonLabelColor,
                        onPressed: isLoading ? null : onTapLeftButton,
                        label: leftButtonLabel!,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // Confirm Button
                    Expanded(
                      child: CustomButton(
                        height: 38.h,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        bordersColor: rightButtonLabelColor,
                        backgroundColor: rightButtonBgColor,
                        foregroundColor: rightButtonLabelColor,
                        onPressed: isLoading ? null : onTapRightButton,
                        label: rightButtonLabel!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}