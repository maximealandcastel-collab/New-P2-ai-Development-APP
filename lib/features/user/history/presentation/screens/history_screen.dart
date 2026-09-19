import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
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
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              preferredSize: Size.fromHeight(62.h),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                child: Obx(
                  () => Container(
                    height: 50.h,
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildTabItem(context, controller, 'All', 0),
                        _buildTabItem(context, controller, 'Pending', 1),
                        _buildTabItem(context, controller, 'Complete', 2),
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
                return _emptyState(
                  controller,
                  'Failed to load history. Please try again.',
                );
              case LoadingState.loaded:
                if (controller.workouts.isEmpty) {
                  return _emptyState(
                    controller,
                    'No workouts yet. Your generated plans will appear here.',
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 130.h),
                  sliver: SliverList.builder(
                    itemCount: controller.workouts.length,
                    itemBuilder: (context, index) {
                      final workout = controller.workouts[index];
                      return HistoryCard(
                        key: ValueKey(workout.id ?? 'workout-$index'),
                        workout: workout,
                        onViewDetails: () =>
                            controller.openWorkoutDetails(workout),
                        onDismiss: () =>
                            controller.dismissWorkout(workout),
                        onRetryGeneration: () =>
                            controller.retryGeneration(workout),
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

  Widget _emptyState(HistoryController controller, String message) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 130.h),
      sliver: SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyDataWidget(
          message: message,
          onRefresh: controller.refresh,
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    HistoryController controller,
    String label,
    int index,
  ) {
    final isSelected = controller.selectedTab == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => controller.onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1,
              fontWeight: AppFontWeight.label,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : const Color(0xFF777982),
            ),
          ),
        ),
      ),
    );
  }
}
