import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_plan_details_content.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_plan_details_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutPlanDetailsScreen extends StatelessWidget {
  const WorkoutPlanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutController.to;

    return Obx(() {
      final isLoading = controller.detailsLoadingState.isLoading;
      final plan = controller.plan;

      return SliverScaffold(
        appBar: const CustomSliverAppBar(
          title: 'View full workout plan',
          pinned: true,
        ),
        onRefresh: controller.detailsWorkoutId != null
            ? controller.refreshWorkoutDetails
            : null,
        refreshEdgeOffset: MediaQuery.sizeOf(context).height * 0.1,
        bodyList: isLoading
            ? WorkoutPlanDetailsShimmer.contentSlivers()
            : _buildBodyList(controller, plan),
        bottomNavigationBar: !isLoading && controller.showSessionButton
            ? CustomButton(
                radius: 12.r,
                label: controller.isSessionInProgress
                    ? 'Complete Session'
                    : 'Session Start',
                isLoading: controller.isSessionInProgress
                    ? false
                    : controller.startSessionLoadingState.isLoading,
                onPressed: controller.onSessionAction,
              )
            : null,
      );
    });
  }

  List<Widget> _buildBodyList(WorkoutController controller, plan) {
    if (plan == null) {
      return [
        _buildUnavailablePlan().asSliverWithPadding(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        SizedBox(height: 200.h).asSliver,
      ];
    }

    return [
      WorkoutPlanDetailsContent(plan: plan)
          .asSliverWithPadding(horizontal: 16.w, vertical: 12.h),
      CustomButton(
        backgroundColor: const Color(0xffE7A700),
        radius: 12.r,
        label: 'Watch Video',
        onPressed: controller.hasVideo ? controller.watchVideo : null,
        isDisabled: !controller.hasVideo,
      ).asSliverWithPadding(horizontal: 16.w, vertical: 12.h),
      SizedBox(height: 200.h).asSliver,
    ];
  }

  Widget _buildUnavailablePlan() {
    return CustomContainer(
      width: double.infinity,
      paddingAll: 18.r,
      radiusAll: 20.r,
      color: AppColors.textWhite,
      bordersColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Workout Plan',
            fontSize: 16.sp,
            fontWeight: AppFontWeight.section,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: StringFormat.valueOrNa(null),
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
