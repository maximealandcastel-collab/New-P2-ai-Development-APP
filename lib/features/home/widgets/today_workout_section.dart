import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/user_home_controller.dart';
import 'package:pler_to_pler_app/features/home/widgets/empty_data.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_exercise_section.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TodayWorkoutSection extends GetView<UserHomeController> {
  const TodayWorkoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mainWork = controller.plan?.mainWork;
      if (mainWork == null || mainWork.isEmpty) {
        return EmptyData(
          title: 'Today’s assigned workout',
          subtitle: 'Not enough data to view',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: 'Today’s assigned workout',
            fontWeight: FontWeight.w600,
            bottom: 12.h,
          ),
          WorkoutExerciseSection(title: 'Main Work', exercises: mainWork),
          SizedBox(height: 12.h),
          CustomButton(
            radius: 12.r,
            label: 'View full workout plan',
            onPressed: controller.openFullWorkoutPlan,
          ),
        ],
      );
    });
  }
}
