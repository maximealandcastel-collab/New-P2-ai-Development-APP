import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/widgets/gradient_ring_loader.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutGeneratingScreen extends StatefulWidget {
  const WorkoutGeneratingScreen({super.key});

  @override
  State<WorkoutGeneratingScreen> createState() =>
      _WorkoutGeneratingScreenState();
}

class _WorkoutGeneratingScreenState extends State<WorkoutGeneratingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WorkoutController.to.generateWorkout();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutController.to;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Obx(() {
          switch (controller.generateLoadingState) {
            case LoadingState.error:
              return EmptyDataWidget(
                message: 'Could not generate your workout plan.',
                onRefresh: controller.generateWorkout,
              );
            case LoadingState.initial:
            case LoadingState.loading:
            case LoadingState.loaded:
            case LoadingState.offline:
              return _buildLoadingContent();
          }
        }),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Padding(
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
          SizedBox(height: 60.h),
          GradientRingLoader(size: 200.r, strokeWidth: 7),
          SizedBox(height: 24.h),
          CustomText(
            text: 'Might take 1~2 minutes',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
            color: AppColors.textSecondary,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
