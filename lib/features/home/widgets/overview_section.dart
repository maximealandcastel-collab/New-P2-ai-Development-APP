import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/user_home_controller.dart';
import 'package:pler_to_pler_app/features/home/widgets/empty_data.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_today_overview_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class OverviewSection extends GetView<UserHomeController> {
  const OverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final overview = controller.todayOverview.value;
      if (overview == null) {
        return EmptyData(title: "Today's overview", subtitle: "Not enough data to view");
      }

      return _buildOverviewContent(overview);
    });
  }

  Widget _buildOverviewContent(WorkoutTodayOverviewModel overview) {
    final completionPercentage = overview.completionPercentage ?? 0;
    final progressValue = (completionPercentage / 100).clamp(0.0, 1.0);

    return CustomContainer(
      color: Colors.white,
      radiusAll: 16.r,
      paddingAll: 14.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "Today's overview",
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 12.h),
          CustomContainer(
            paddingAll: 18.r,
            bordersColor: AppColors.secondary,
            radiusAll: 16.r,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressCircle(
                      progressValue,
                      '$completionPercentage%',
                    ),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: Column(
                        children: [
                          _buildOverviewItem(
                            Icons.gps_fixed,
                            Colors.orange.shade100,
                            Colors.orange,
                            'Goal',
                            StringFormat.formatSelectedList(
                              overview.goal ?? [],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _buildOverviewItem(
                            Icons.accessibility_new,
                            Colors.blue.shade100,
                            Colors.blue,
                            'Focus Area',
                            StringFormat.formatSelectedList(
                              overview.focusArea ?? [],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _buildOverviewItem(
                            Icons.access_time,
                            Colors.green.shade100,
                            Colors.green,
                            'Duration',
                            '${overview.duration ?? 0} Minutes',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Divider(color: AppColors.primary, thickness: 0.1),
                SizedBox(height: 10.h),
                _buildDetailItem(
                  Icons.local_fire_department_outlined,
                  Colors.orange,
                  'Workout Intensity',
                  StringFormat.formatSelectedList(
                    overview.workoutIntensity ?? [],
                  ),
                ),
                SizedBox(height: 14.h),
                _buildDetailItem(
                  Icons.fitness_center,
                  Colors.purple,
                  'Equipment Availability',
                  StringFormat.formatSelectedList(
                    overview.equipmentAvailability ?? [],
                  ),
                ),
                SizedBox(height: 14.h),
                Divider(color: AppColors.primary, thickness: 0.1),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    CustomText(
                      text: 'Workout Environment:',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomText(
                        text: StringFormat.formatSelectedList(
                          overview.workoutEnvironment ?? [],
                        ),
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(double progressValue, String label) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        SizedBox(
          height: 80.h,
          width: 80.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80.h,
                width: 80.w,
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 10.h,
                  backgroundColor: AppColors.secondary,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              CustomText(
                text: label,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
        CustomText(
          top: 10.h,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          text: 'Exercise',
        ),
      ],
    );
  }

  Widget _buildOverviewItem(
    IconData icon,
    Color bgColor,
    Color iconColor,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          height: 36.h,
          width: 36.w,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 18.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: title,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              CustomText(
                text: subtitle.isEmpty ? 'N/A' : subtitle,
                fontSize: 12.sp,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 34.h,
          width: 34.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.sp, color: iconColor),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: title,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 2.h),
              CustomText(
                text: subtitle.isEmpty ? 'N/A' : subtitle,
                fontSize: 12.sp,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
