import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
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

          /// Main Card
          CustomContainer(
            paddingAll: 18.r,
            bordersColor: AppColors.secondary,
            radiusAll: 16.r,
            child: Column(
              children: [
                /// Top Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Progress Circle
                    Column(
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
                                  value: .68,
                                  strokeWidth: 10.h,
                                  backgroundColor: AppColors.secondary,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                              CustomText(
                                text: '68%',
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
                    ),

                    SizedBox(width: 24.w),

                    /// Right Content
                    Expanded(
                      child: Column(
                        children: [
                          _overviewItem(
                            Icons.gps_fixed,
                            Colors.orange.shade100,
                            Colors.orange,
                            'Goal',
                            'Maintain physique',
                          ),
                          SizedBox(height: 12.h),
                          _overviewItem(
                            Icons.accessibility_new,
                            Colors.blue.shade100,
                            Colors.blue,
                            'Focus Area',
                            'Upper body, chest',
                          ),
                          SizedBox(height: 12.h),
                          _overviewItem(
                            Icons.access_time,
                            Colors.green.shade100,
                            Colors.green,
                            'Duration',
                            '60 Minutes',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                Divider(color: AppColors.primary, thickness: 0.1),

                SizedBox(height: 10.h),

                _detailItem(
                  Icons.local_fire_department_outlined,
                  Colors.orange,
                  'Workout Intensity',
                  'Moderate',
                ),

                SizedBox(height: 14.h),

                _detailItem(
                  Icons.fitness_center,
                  Colors.purple,
                  'Equipment Availability',
                  'Barbell, Dumbbells, Cable, Machine, Bench',
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
                    CustomText(
                      text: 'Full Gym',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
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

  Widget _overviewItem(
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
                text: subtitle,
                fontSize: 12.sp,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailItem(
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
            color: iconColor.withOpacity(.12),
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
                text: subtitle,
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
