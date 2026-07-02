import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_plan_details_content.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutPlanDetailsScreen extends StatelessWidget {
  const WorkoutPlanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutController.to;

    return Obx(() {
      final plan = controller.plan;

      return SliverScaffold(
        appBar: const CustomSliverAppBar(
          title: 'View full workout plan',
          pinned: true,
        ),
        bodyList: [
          if (plan == null)
            const EmptyDataWidget(message: 'Workout plan not available.')
                .asFillRemainingSliver()
          else ...[
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
          ],
        ],
        bottomNavigationBar: Obx(
          () => CustomButton(
            radius: 12.r,
            label: controller.isSessionInProgress
                ? 'Complete Session'
                : 'Session Start',
            isLoading: controller.isSessionInProgress
                ? controller.completeSessionLoadingState.isLoading
                : controller.startSessionLoadingState.isLoading,
            onPressed: controller.onSessionAction,
          ),
        ),
      );
    });
  }
}
