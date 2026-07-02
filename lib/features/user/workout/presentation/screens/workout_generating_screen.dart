import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutGeneratingScreen extends StatelessWidget {
  const WorkoutGeneratingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              CustomText(
                text: 'Finding best workout plan\nfor you',
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: 'What you want to achieve from the workout',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 40.h),
              const CustomLoader(),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
