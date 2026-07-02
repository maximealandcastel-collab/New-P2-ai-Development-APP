import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/widgets/workout_multi_select_field.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutIntensityDurationPage extends StatelessWidget {
  const WorkoutIntensityDurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutController.to;

    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CompleteProfilePageTitle(text: 'Intensity & duration'),
          SizedBox(height: 16.h),
          WorkoutMultiSelectField(
            options: HelperData.workoutIntensityOptions,
            selectedValues: controller.selectedIntensities.toList(),
            onChanged: controller.onIntensitiesChanged,
          ),
          SizedBox(height: 24.h),
          CustomText(
            text: 'Duration (minutes)',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: HelperData.workoutDurationOptions.map((minutes) {
              final isSelected = controller.selectedDuration.value == minutes;
              return CustomContainer(
                onTap: () => controller.onDurationSelected(minutes),
                paddingHorizontal: 14.w,
                paddingVertical: 10.h,
                radiusAll: 99.r,
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.backgroundLight,
                bordersColor:
                    isSelected ? AppColors.primary : AppColors.colorE6E6E6,
                child: CustomText(
                  text: '$minutes min',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color:
                      isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
