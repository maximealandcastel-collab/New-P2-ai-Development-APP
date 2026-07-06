import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/user_home_controller.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/home/widgets/gym_section.dart';
import 'package:pler_to_pler_app/features/home/widgets/overview_section.dart';
import 'package:pler_to_pler_app/features/home/widgets/today_workout_section.dart';
import 'package:pler_to_pler_app/features/home/widgets/user_home_shimmer.dart';
import 'package:pler_to_pler_app/features/home/widgets/week_date_picker.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class UserHomeScreen extends GetView<UserHomeController> {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.toNamed(AppRoute.workoutScreen),
              child: Assets.images.setGoal.image(),
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
      const TodayWorkoutSection()
          .asSliverWithPadding(horizontal: 16.w, vertical: 14.h),
    ];
  }
}
