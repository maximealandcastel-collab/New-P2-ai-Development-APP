import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/user/history/presentation/controllers/history_controller.dart';
import 'package:pler_to_pler_app/features/user/history/presentation/screens/widgets/history_card.dart';
import 'package:pler_to_pler_app/features/user/history/presentation/screens/widgets/history_shimmer.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
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
              preferredSize: Size.fromHeight(66.h),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                child: Obx(
                  () => Container(
                    height: 56.h,
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17.r),
                      border: Border.all(color: const Color(0xFFF0F0F2)),
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
                        _buildTabItem(
                          context,
                          controller,
                          'All',
                          'All workouts',
                          Icons.grid_view_rounded,
                          0,
                        ),
                        _buildTabItem(
                          context,
                          controller,
                          'Pending',
                          'Need review',
                          Icons.schedule_rounded,
                          1,
                        ),
                        _buildTabItem(
                          context,
                          controller,
                          'Complete',
                          'Finished',
                          Icons.check_circle_outline_rounded,
                          2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 8.h),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Workouts',
                          style: TextStyle(
                            fontSize: 20.sp,
                            height: 1.1,
                            fontWeight: AppFontWeight.section,
                            color: const Color(0xFF17181C),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Track and manage your workout plans',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            height: 1.2,
                            fontWeight: AppFontWeight.body,
                            color: const Color(0xFF858791),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Obx(
                    () => PopupMenuButton<bool>(
                      tooltip: 'Sort workouts',
                      initialValue: controller.latestFirst,
                      onSelected: controller.setLatestFirst,
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: true, child: Text('Latest first')),
                        PopupMenuItem(value: false, child: Text('Oldest first')),
                      ],
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 9.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999.r),
                          border: Border.all(color: const Color(0xFFF0F0F2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_vert_rounded,
                              size: 17.sp,
                              color: const Color(0xFF686B75),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              controller.latestFirst ? 'Latest' : 'Oldest',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: AppFontWeight.label,
                                color: const Color(0xFF545761),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 17.sp,
                              color: const Color(0xFF686B75),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 130.h),
                  sliver: SliverList.builder(
                    itemCount: controller.displayedWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = controller.displayedWorkouts[index];
                      return HistoryCard(
                        key: ValueKey(workout.id ?? 'workout-$index'),
                        workout: workout,
                        onViewDetails: () =>
                            controller.openWorkoutDetails(workout),
                        onDismiss: () =>
                            controller.dismissWorkout(workout),
                        onRetryGeneration: () =>
                            controller.retryGeneration(workout),
                        onAssignedClientsTap: workout.assignedClients.isEmpty
                            ? null
                            : () => _showAssignedClients(
                                  context,
                                  workout.assignedClients,
                                ),
                        onClientTap: workout.assignedClients.isEmpty
                            ? null
                            : (_) => _showAssignedClients(
                                  context,
                                  workout.assignedClients,
                                ),
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
    String caption,
    IconData icon,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17.sp,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : const Color(0xFF777982),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1,
                        fontWeight: AppFontWeight.label,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : const Color(0xFF545761),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        height: 1,
                        fontWeight: AppFontWeight.body,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.84)
                            : const Color(0xFF9698A0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignedClients(
    BuildContext context,
    List<WorkoutAssignedClient> clients,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assigned clients',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: AppFontWeight.section,
                  color: const Color(0xFF17181C),
                ),
              ),
              SizedBox(height: 10.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 420.h),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: clients.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final client = clients[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CustomNetworkImage(
                        imageUrl: client.profilePicture,
                        height: 40.r,
                        width: 40.r,
                        boxShape: BoxShape.circle,
                        backgroundColor: const Color(0xFFFFF1E7),
                        fallbackAsset: Center(
                          child: Text(
                            client.initials,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: AppFontWeight.label,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        client.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: AppFontWeight.label,
                        ),
                      ),
                      subtitle: Text(
                        'Assigned to this workout',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF858791),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
