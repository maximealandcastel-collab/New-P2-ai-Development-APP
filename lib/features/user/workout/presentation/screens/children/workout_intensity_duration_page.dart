import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/Intensity_option.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/duration_ruler_picker.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutIntensityDurationPage extends StatelessWidget {
  const WorkoutIntensityDurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CompleteProfilePageTitle(text: 'Workout Intensity & duration'),
        SizedBox(height: 44.h),

        CustomText(
          text: 'Workout Intensity',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 12.h),
        Obx(
          () => WorkoutIntensitySelector(
            options: const [
              IntensityOption(
                value: 'easy',
                label: 'Easy',
                icon: Icons.directions_run_rounded,
              ),
              IntensityOption(
                value: 'medium',
                label: 'Medium',
                icon: Icons.self_improvement_rounded,
              ),
              IntensityOption(
                value: 'hard',
                label: 'Hard',
                icon: Icons.fitness_center_rounded,
              ),
            ],
            selectedValue: controller.selectedIntensities.isEmpty
                ? null
                : controller.selectedIntensities.first,
            onChanged: controller.onIntensitySelected,
          ),
        ),
        SizedBox(height: 24.h),
        CustomText(
          text: 'Workout Duration (minutes)',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 12.h),
        DurationRulerPicker(
          min: 1,
          max: 120,
          initialValue: controller.selectedDuration.value,
          onChanged: controller.onDurationSelected,
        ),
      ],
    );
  }
}
