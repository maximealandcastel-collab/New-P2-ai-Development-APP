import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_exercise_card.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutExerciseSection extends StatelessWidget {
  const WorkoutExerciseSection({
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
            fontWeight: FontWeight.w800,
            left: 4.w,
            bottom: 10.h,
          ),
          ...sortedExercises.map(
            (exercise) => WorkoutExerciseCard(exercise: exercise),
          ),
        ],
      ),
    );
  }
}
