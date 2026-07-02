import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutPlanChipSection extends StatelessWidget {
  const WorkoutPlanChipSection({
    super.key,
    required this.title,
    required this.values,
  });

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 12.r,
      color: AppColors.textWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            left: 4.w,
            bottom: 10.h,
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: values
                .map(
                  (value) => CustomContainer(
                    paddingHorizontal: 14.w,
                    paddingVertical: 6.h,
                    radiusAll: 99.r,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: CustomText(
                      text: StringFormat.formatLabel(value),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
