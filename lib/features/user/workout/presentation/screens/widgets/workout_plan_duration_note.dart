import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutPlanDurationNote extends StatelessWidget {
  const WorkoutPlanDurationNote({super.key, required this.plan});

  final WorkoutAiPlanModel plan;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 16.r,
      color: AppColors.textWhite,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Duration in min: ${plan.estimatedDurationMinutes}',
            fontWeight: AppFontWeight.label,
            color: Theme.of(context).colorScheme.primary,
          ),
          if ((plan.checkInQuestion ?? '').isNotEmpty) ...[
            SizedBox(height: 6.h),
            CustomText(
              text: plan.checkInQuestion!,
              fontSize: 13.sp,
              textAlign: TextAlign.start,
            ),
          ],
        ],
      ),
    );
  }
}
