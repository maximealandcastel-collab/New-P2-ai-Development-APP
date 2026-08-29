import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutMetricChip extends StatelessWidget {
  const WorkoutMetricChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      paddingHorizontal: 10.w,
      paddingVertical: 7.h,
      radiusAll: 10.r,
      color: AppColors.backgroundLight,
      child: CustomText(
        text: label,
        fontSize: 12.sp,
        fontWeight: AppFontWeight.label,
        color: AppColors.textSecondary,
      ),
    );
  }
}
