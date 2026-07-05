import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RequestProfileChip extends StatelessWidget {
  const RequestProfileChip({
    super.key,
    required this.label,
    this.highlighted = false,
  });

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999.r),
        border: highlighted
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.35))
            : null,
      ),
      child: CustomText(
        text: label,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: highlighted ? AppColors.primary : AppColors.textPrimary,
        textAlign: TextAlign.start,
      ),
    );
  }
}
