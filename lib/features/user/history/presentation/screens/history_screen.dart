import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/user/history/presentation/controllers/history_controller.dart';
import 'package:pler_to_pler_app/features/user/history/presentation/screens/widgets/history_card.dart';
import 'package:pler_to_pler_app/features/user/history/presentation/screens/widgets/history_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HistoryController.to;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundLight,
      onRefresh: controller.refresh,
      edgeOffset: MediaQuery.heightOf(context) * 0.2,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          FeedAppBarSliver(
            pinned: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(70.h),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                child: Obx(
                  () => CustomContainer(
                    radiusAll: 14.r,
                    color: Colors.white,
                    paddingAll: 4.r,
                    child: Row(
                      children: [
                        _buildTabItem(
                          controller: controller,
                          label: 'All',
                          index: 0,
                        ),
                        _buildTabItem(
                          controller: controller,
                          label: 'Pending',
                          index: 1,
                        ),
                        _buildTabItem(
                          controller: controller,
                          label: 'Complete',
                          index: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            switch (controller.loadingState) {
              case LoadingState.initial:
              case LoadingState.loading:
                return const HistoryShimmer().asSliver;
              case LoadingState.offline:
              case LoadingState.error:
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 130.h),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyDataWidget(
                      message: 'Failed to load history. Please try again.',
                      onRefresh: controller.refresh,
                    ),
                  ),
                );
              case LoadingState.loaded:
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 130.h),
                  sliver: SliverList.builder(
                    itemCount: controller.workouts.length,
                    itemBuilder: (context, index) {
                      final workout = controller.workouts[index];
                      return HistoryCard(
                        workout: workout,
                        onViewDetails: () =>
                            controller.openWorkoutDetails(workout),
                      );
                    },
                  ),
                );
            }
          }),
          PaginationLoaderSliver(controller: controller),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required HistoryController controller,
    required String label,
    required int index,
  }) {
    final isSelected = controller.selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onTabSelected(index),
        child: CustomContainer(
          radiusAll: 12.r,
          paddingVertical: 12.h,
          color: isSelected ? Colors.black : Colors.transparent,
          alignment: Alignment.center,
          child: CustomText(
            text: label,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
