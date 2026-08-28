import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutTimedStepSection extends StatelessWidget {
  const WorkoutTimedStepSection({
    super.key,
    required this.title,
    required this.steps,
  });

  final String title;
  final List<WorkoutPlanStepModel> steps;

  @override
  Widget build(BuildContext context) {
    final sortedSteps = [...steps]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 16.r,
      color: AppColors.textWhite,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontSize: 17.sp,
            fontWeight: AppFontWeight.display,
            left: 4.w,
            bottom: 10.h,
          ),
          CustomContainer(
            paddingAll: 16.r,
            radiusAll: 16.r,
            bordersColor: AppColors.secondary,
            child: Column(
              children: sortedSteps
                  .asMap()
                  .entries
                  .map(
                    (entry) => _buildTimedStepRow(
                      index: entry.key + 1,
                      step: entry.value,
                      isLast: entry.key == sortedSteps.length - 1,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimedStepRow({
    required int index,
    required WorkoutPlanStepModel step,
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: '$index.',
            fontSize: 14.sp,
            fontWeight: AppFontWeight.label,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: AppFontWeight.label,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(text: '${step.instruction ?? ''} — '),
                      TextSpan(
                        text: step.duration ?? '',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                if ((step.tip ?? '').isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  CustomText(
                    text: step.tip!,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.start,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
