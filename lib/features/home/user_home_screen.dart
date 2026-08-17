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
// Matches the branded P2P design: dark left panel + orange right panel with
// diagonal cut and icon grid. Always visible on the user home screen.
class _WorkoutSplitBanner extends StatelessWidget {
  const _WorkoutSplitBanner();

  static const _dark   = Color(0xFF141414);
  static const _orange = Color(0xFFFD7B00);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 168.h,
      decoration: BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          // ── Left: text + CTA ───────────────────────────────────────────
          Expanded(
            flex: 58,
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 8.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CREATE YOUR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.8,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'WORKOUT\n',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: 'SPLIT',
                          style: TextStyle(
                            color: _orange,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    'Design a plan that fits your goals,\nyour body, and your lifestyle.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 9.5.sp,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      // GET STARTED pill
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'GET STARTED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 11.sp),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'P2P FIT TECH AI',
                    style: TextStyle(
                      color: _orange,
                      fontSize: 7.5.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Right: orange panel with diagonal cut + icons ─────────────
          Expanded(
            flex: 42,
            child: ClipPath(
              clipper: _DiagonalClipper(),
              child: Container(
                color: _orange,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _iconTile(Icons.calendar_month_rounded),
                      SizedBox(height: 10.h),
                      _iconTile(Icons.fitness_center_rounded),
                      SizedBox(height: 10.h),
                      _iconTile(Icons.track_changes_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconTile(IconData icon) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: Colors.white, size: 22.r),
    );
  }
}

/// Clips the orange right panel with an angled left edge to match the
/// diagonal split seen in the mockup.
class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(28, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_DiagonalClipper _) => false;
}
