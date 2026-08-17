import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/user_home_controller.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/home/widgets/gym_section.dart';
import 'package:pler_to_pler_app/features/home/widgets/overview_section.dart';
import 'package:pler_to_pler_app/features/home/widgets/today_workout_section.dart';
import 'package:pler_to_pler_app/features/home/widgets/trainer_plan_section.dart';
import 'package:pler_to_pler_app/features/home/widgets/user_home_shimmer.dart';
import 'package:pler_to_pler_app/features/home/widgets/week_date_picker.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserHomeController.to;

    return Obx(() {
      final showShimmer = controller.showShimmer;

      return RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.backgroundLight,
        edgeOffset: MediaQuery.sizeOf(context).height * 0.12,
        onRefresh: controller.refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            const FeedAppBarSliver(),
            WeekDatePicker(
              onDateSelected: (date) {
                debugPrint('Selected: $date');
              },
            ).asSliver,
            if (showShimmer) ...UserHomeShimmer.slivers() else ..._buildContent(controller),
            SizedBox(height: 16.h).asSliver,
            SliverToBoxAdapter(child: SizedBox(height: 120.h)),
          ],
        ),
      );
    });
  }

  List<Widget> _buildContent(UserHomeController controller) {
    final hasWorkout = controller.todayOverview.value != null;
    return [
      GymSection().asSliverWithPadding(horizontal: 16.w),
      // Workout split banner — always visible so users can regenerate their plan
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.toNamed(AppRoute.workoutScreen),
        child: const _WorkoutSplitBanner(),
      ).asSliverWithPadding(horizontal: 16.w, vertical: 12.h),
      // Today's overview + workout details only appear after the user has
      // created their workout plan for the first time
      if (hasWorkout) ...[
        OverviewSection().asSliverWithPadding(horizontal: 16.w, vertical: 14.h),
        const TodayWorkoutSection().asSliverWithPadding(horizontal: 16.w),
      ],
      const TrainerPlanSection().asSliverWithPadding(horizontal: 16.w),
    ];
  }
}

// ─── Workout Split Banner ───────────────────────────────────────────────────
// Slim branded card: P2P logo + title + orange accent panel. Always visible.
class _WorkoutSplitBanner extends StatelessWidget {
    const _WorkoutSplitBanner();

    @override
    Widget build(BuildContext context) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.asset(
          'assets/images/workout_split_banner.png',
          width: double.infinity,
          height: 112.h,
          fit: BoxFit.cover,
        ),
      );
    }
    }
