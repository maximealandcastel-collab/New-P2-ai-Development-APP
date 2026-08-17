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

  static const _dark   = Color(0xFF0F0F0F);
  static const _orange = Color(0xFFFD7B00);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 112.h,
      decoration: BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          // ── Left: logo + title + CTA ───────────────────────────────────
          Expanded(
            flex: 60,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 8.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand row: logo + name
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/p2p_logo.jpg',
                          width: 24.r,
                          height: 24.r,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 7.w),
                      Text(
                        'P2P FIT TECH AI',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  // Headline
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CREATE YOUR',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.8,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'WORKOUT ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            TextSpan(
                              text: 'SPLIT',
                              style: TextStyle(
                                color: _orange,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // CTA pill
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: _orange,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'GET STARTED  →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Right: diagonal orange gradient panel ──────────────────────
          ClipPath(
            clipper: _DiagonalClipper(),
            child: Container(
              width: 108.w,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFE9A2E), Color(0xFFFD7B00)],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 34.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clips the orange right panel with an angled left edge.
class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(26, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_DiagonalClipper _) => false;
}
