import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_exercise_section.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_finisher_section.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_plan_chip_section.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_plan_duration_note.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_plan_header.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_plan_info_card.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_timed_step_section.dart';

class WorkoutPlanDetailsContent extends StatelessWidget {
  const WorkoutPlanDetailsContent({super.key, required this.plan});

  final WorkoutAiPlanModel plan;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WorkoutPlanHeader(plan: plan),
        if (plan.warmUp?.isNotEmpty ?? false) ...[
          SizedBox(height: 12.h),
          WorkoutTimedStepSection(title: 'Warm up', steps: plan.warmUp!),
        ],
        if (plan.mainWork?.isNotEmpty ?? false) ...[
          SizedBox(height: 10.h),
          WorkoutExerciseSection(title: 'Main Work', exercises: plan.mainWork!),
        ],
        if (plan.accessories?.isNotEmpty ?? false) ...[
          SizedBox(height: 10.h),
          WorkoutExerciseSection(
            title: 'Accessories',
            exercises: plan.accessories!,
          ),
        ],
        if (plan.finisher?.isNotEmpty ?? false) ...[
          SizedBox(height: 10.h),
          WorkoutFinisherSection(title: 'Finisher', exercises: plan.finisher!),
        ],
        if (plan.coolDown?.isNotEmpty ?? false) ...[
          SizedBox(height: 10.h),
          WorkoutTimedStepSection(title: 'Cool Down', steps: plan.coolDown!),
        ],
        if ((plan.nutritionTip ?? '').isNotEmpty) ...[
          SizedBox(height: 10.h),
          WorkoutPlanInfoCard(title: 'Nutrition Tip', body: plan.nutritionTip!),
        ],
        if (plan.thisWeekFocus?.isNotEmpty ?? false) ...[
          SizedBox(height: 10.h),
          WorkoutPlanChipSection(
            title: 'This Week Focus',
            values: plan.thisWeekFocus!,
          ),
        ],
        if (plan.estimatedDurationMinutes != null) ...[
          SizedBox(height: 10.h),
          WorkoutPlanDurationNote(plan: plan),
        ],
      ],
    );
  }
}
