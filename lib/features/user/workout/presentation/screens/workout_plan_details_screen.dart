import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_plan_details_content.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutPlanDetailsScreen extends StatelessWidget {
  const WorkoutPlanDetailsScreen({super.key});

  WorkoutModel get _workout => Get.arguments as WorkoutModel;

  WorkoutAiPlanModel? get _plan => _workout.aiPlan;

  bool get _hasVideo {
    final video = _plan?.suggestedVideo?.trim() ?? '';
    return video.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;

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
          SizedBox(height: 120.h).asSliver,
        ],
      ],
      bottomNavigationBar: CustomButton(
        label: _hasVideo ? 'Complete Exercise' : 'Go home',
        onPressed: _hasVideo ? _watchVideo : _goHome,
      ),
    );
  }

  void _goHome() {
    if (Get.isRegistered<BottomNavBarController>()) {
      BottomNavBarController.to.resetIndex();
    }
    Get.offAllNamed(AppRoute.bottonNavBar);
  }

  void _watchVideo() {
    final videoUrl = _plan?.suggestedVideo?.trim();
    if (videoUrl == null || videoUrl.isEmpty) return;

    Get.toNamed(
      AppRoute.workoutVideoScreen,
      arguments: videoUrl,
    );
  }
}
