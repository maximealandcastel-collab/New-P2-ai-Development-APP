import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutPlanHeader extends StatelessWidget {
  const WorkoutPlanHeader({super.key, required this.plan});

  final WorkoutAiPlanModel plan;

  @override
  Widget build(BuildContext context) {
    final todayLabel = StringFormat.formatLabel(
      DateTime.now().toString().split(' ').first,
    );

    return CustomContainer(
      width: double.infinity,
      paddingAll: 18.r,
      radiusAll: 20.r,
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: todayLabel,
            fontSize: 12.sp,
            fontWeight: AppFontWeight.label,
            color: AppColors.textWhite.withValues(alpha: 0.85),
          ),
          SizedBox(height: 6.h),
          CustomText(
            text: (plan.trainerSpecialty ?? '').isNotEmpty
                ? StringFormat.formatLabel(plan.trainerSpecialty!)
                : 'Workout Plan',
            fontSize: 20.sp,
            fontWeight: AppFontWeight.display,
            color: AppColors.textWhite,
          ),
          if ((plan.coachNote ?? '').isNotEmpty) ...[
            SizedBox(height: 8.h),
            CustomText(
              text: plan.coachNote!,
              fontSize: 12.sp,
              fontWeight: AppFontWeight.body,
              color: AppColors.textWhite,
              textAlign: TextAlign.start,
            ),
          ],
        ],
      ),
    );
  }
}
