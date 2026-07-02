import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_metric_chip.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutExerciseCard extends StatelessWidget {
  const WorkoutExerciseCard({
    super.key,
    required this.exercise,
    this.onMarkCompleted,
  });

  final WorkoutExerciseModel exercise;
  final VoidCallback? onMarkCompleted;

  @override
  Widget build(BuildContext context) {
    final steps = [...?exercise.steps]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 12.r,
      marginBottom: 12.h,
      bordersColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomText(
                  textAlign: TextAlign.start,
                  text: exercise.exerciseName ?? '',
                  fontSize: 18.sp,
                  color: const Color(0xff6A3400),
                  fontWeight: FontWeight.w700,
                ),
              ),
              CustomButton(
                onPressed: onMarkCompleted,
                label: 'Mark Completed',
                width: 100.w,
                height: 30.h,
                fontSize: 10.sp,
              ),
            ],
          ),
          if ((exercise.muscleGroup ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              text:
                  'Muscle group: ${StringFormat.formatLabel(exercise.muscleGroup!)}',
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ],
          SizedBox(height: 10.h),
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
              if ((exercise.rpe ?? '').isNotEmpty)
                WorkoutMetricChip(label: 'RPE ${exercise.rpe}'),
            ],
          ),
          if (steps.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Divider(height: 1.h, color: AppColors.colorE6E6E6),
            SizedBox(height: 14.h),
            ...steps.asMap().entries.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key == steps.length - 1 ? 0 : 10.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: '${entry.key + 1}.',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: entry.value.instruction ?? '',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.start,
                              ),
                              if ((entry.value.tip ?? '').isNotEmpty) ...[
                                SizedBox(height: 3.h),
                                CustomText(
                                  text: 'Tip: ${entry.value.tip!}',
                                  fontSize: 11.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
