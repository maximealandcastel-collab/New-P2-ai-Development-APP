import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_metric_chip.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutFinisherSection extends StatelessWidget {
  const WorkoutFinisherSection({
    super.key,
    required this.title,
    required this.exercises,
  });

  final String title;
  final List<WorkoutExerciseModel> exercises;

  @override
  Widget build(BuildContext context) {
    final sortedExercises = [...exercises]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: title,
          fontSize: 17.sp,
          fontWeight: AppFontWeight.display,
          left: 4.w,
          bottom: 10.h,
        ),
        ...sortedExercises.map(_buildFinisherCard),
      ],
    );
  }

  Widget _buildFinisherCard(WorkoutExerciseModel exercise) {
    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 16.r,
      color: AppColors.textWhite,
      width: double.infinity,
      marginBottom: 10.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: exercise.exerciseName ?? 'Exercise',
            fontSize: 15.sp,
            fontWeight: AppFontWeight.section,
          ),
          if ((exercise.muscleGroup ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              text:
                  'Muscle group: ${StringFormat.formatLabel(exercise.muscleGroup!)}',
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ],
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (exercise.sets != null)
                WorkoutMetricChip(label: '${exercise.sets} sets'),
              if ((exercise.reps ?? '').isNotEmpty)
                WorkoutMetricChip(label: '${exercise.reps} reps'),
              if ((exercise.restTime ?? '').isNotEmpty)
                WorkoutMetricChip(label: 'Rest ${exercise.restTime}'),
            ],
          ),
        ],
      ),
    );
  }
}
