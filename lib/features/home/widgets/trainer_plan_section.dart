import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/user_home_controller.dart';
import 'package:pler_to_pler_app/features/home/widgets/empty_data.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_exercise_section.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

/// Shows today's trainer-created workout day on the home screen,
/// using the exact same widgets as the AI workout section.
class TrainerPlanSection extends StatelessWidget {
  const TrainerPlanSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserHomeController.to;

    return Obx(() {
      final plan = controller.trainerPlan;

      // No plan yet – trainer hasn't set one up (shouldn't happen after subscribe,
      // but guard against it gracefully)
      if (plan == null || plan.todayExercises.isEmpty) {
        if (!controller.hasTrainerPlan) return const SizedBox.shrink();
        return EmptyData(
          title: "Today's trainer workout",
          subtitle: 'Your trainer is setting up your program',
        );
      }

      final day = plan.todayDay;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: "Today's trainer workout",
                      fontWeight: FontWeight.w600,
                      bottom: 2.h,
                    ),
                    if ((plan.todayFocus).isNotEmpty)
                      CustomText(
                        text: plan.todayFocus,
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                        bottom: 12.h,
                      ),
                  ],
                ),
              ),
              if ((plan.trainerName ?? '').isNotEmpty)
                CustomText(
                  text: plan.trainerName!,
                  fontSize: 12.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  bottom: 12.h,
                ),
            ],
          ),

          // Warmup note
          if ((day?.warmupNotes ?? '').isNotEmpty)
            CustomContainer(
              radiusAll: 10.r,
              paddingAll: 10.r,
              marginBottom: 10.h,
              color: AppColors.primary.withOpacity(0.07),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.directions_run_rounded,
                      size: 16.sp, color: AppColors.primary),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: CustomText(
                      text: '🔥 Warm-up: ${day!.warmupNotes}',
                      fontSize: 12.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),

          // Exercises — reuse the existing WorkoutExerciseSection widget
          WorkoutExerciseSection(
            title: plan.todayLabel.isNotEmpty ? plan.todayLabel : 'Exercises',
            exercises: plan.todayExercises,
          ),

          SizedBox(height: 10.h),

          // Cooldown note
          if ((day?.cooldownNotes ?? '').isNotEmpty)
            CustomContainer(
              radiusAll: 10.r,
              paddingAll: 10.r,
              marginBottom: 10.h,
              color: AppColors.secondary.withOpacity(0.10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.self_improvement_rounded,
                      size: 16.sp, color: AppColors.secondary),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: CustomText(
                      text: '❄️ Cool-down: ${day!.cooldownNotes}',
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}
