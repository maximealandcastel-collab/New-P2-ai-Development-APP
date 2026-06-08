import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import '../widgets/widgets.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? cancelButtonText;
  final String? confirmButtonText;
  final Color? confirmButtonColor;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;

  const CustomDialog({
    super.key,
    required this.title,
    this.cancelButtonText = "Cancel",
    this.confirmButtonText = "Delete",
     this.onCancel,
    required this.onConfirm, this.confirmButtonColor,  this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Text
            CustomText(
              textAlign: TextAlign.start,
              text: title,
              fontSize: 18.sp,
              color: Colors.black,
              maxline: 2,
            ),

            if(subtitle != null)
            CustomText(
              top: 10.h,
              textAlign: TextAlign.start,
              text: subtitle!,
              fontSize: 16.sp,
              color: Colors.black,
              maxline: 2,
            ),
            SizedBox(height: 24.h),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel Button
                Expanded(
                  child: TextButton(
                    onPressed: onCancel ?? () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor:  Colors.transparent,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: AppColors.textPrimary),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: CustomText(
                      text: cancelButtonText!,
                      color:AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                // Confirm Button
                Expanded(
                  child: TextButton(
                    onPressed: onConfirm,
                    style: TextButton.styleFrom(
                      backgroundColor:confirmButtonColor ?? Color(0xffE11E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: CustomText(
                      text: confirmButtonText!,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
