import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/custom_button.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({
    super.key,
    required this.message,
    this.onRefresh,
  });

  final String message;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: message,
            textAlign: TextAlign.center,
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
          if (onRefresh != null) ...[
            SizedBox(height: 16.h),
            CustomButton(
              height: 40.h,
              width: 140.w,
              label: 'Try again',
              onPressed: onRefresh,
            ),
          ],
        ],
      ),
    );
  }
}
