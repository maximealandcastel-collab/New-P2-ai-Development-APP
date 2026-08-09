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
            if (controller.todayOverview.value == null)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.toNamed(AppRoute.workoutScreen),
                child: const _WorkoutSplitBanner(),
              ).asSliverWithPadding(horizontal: 16.w, vertical: 10.h),
            if (showShimmer) ...UserHomeShimmer.slivers() else ..._buildContent(),
            SizedBox(height: 16.h).asSliver,
            SliverToBoxAdapter(child: SizedBox(height: 120.h)),
          ],
        ),
      );
    });
  }

  List<Widget> _buildContent() {
    return [
      GymSection().asSliverWithPadding(horizontal: 16.w),
      OverviewSection().asSliverWithPadding(horizontal: 16.w, vertical: 14.h),
      const TodayWorkoutSection().asSliverWithPadding(horizontal: 16.w),
      const TrainerPlanSection().asSliverWithPadding(horizontal: 16.w),
    ];
  }
}

/// Replaces the old 'Set your goal' image asset with a Flutter widget
/// so the button text can be updated without regenerating image assets.
class _WorkoutSplitBanner extends StatelessWidget {
  const _WorkoutSplitBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 148.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B7A99), Color(0xFF9AA5B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6.w,
            bottom: 0,
            top: 0,
            child: Icon(
              Icons.fitness_center,
              size: 110.sp,
              color: Colors.white.withOpacity(0.13),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Leverage power of AI to find\nworkout that fits your needs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Text(
                    'Create my workout split',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
