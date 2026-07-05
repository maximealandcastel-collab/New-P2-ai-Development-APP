import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_exercise_section.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TodayWorkoutSection extends GetView<WorkoutController> {
  const TodayWorkoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.todayWorkoutLoadingState.isLoading) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: const Center(child: CustomLoader()),
        );
      }

      final mainWork = controller.plan?.mainWork;
      if (mainWork == null || mainWork.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(text: 'Today’s assigned workout',fontWeight: FontWeight.w600,bottom: 12.h,),
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
