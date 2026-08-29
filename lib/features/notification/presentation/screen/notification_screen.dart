import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/notification/presentation/controllers/notification_controller.dart';
import 'package:pler_to_pler_app/features/notification/presentation/screen/widgets/notification_card_widget.dart';
import 'package:pler_to_pler_app/features/notification/presentation/screen/widgets/notification_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.to;
    controller.ensureListLoaded();

    return SliverScaffold(
      refreshEdgeOffset: MediaQuery.sizeOf(context).height * 0.12,
      onRefresh: controller.refresh,
      paginationList: controller.notificationsList,
      appBar: CustomSliverAppBar(
        title: 'Notifications',
        actions: [
          Obx(() {
            if (!controller.hasUnread) return const SizedBox.shrink();

            return TextButton(
              onPressed: controller.markAllAsRead,
              child: CustomText(
                text: 'Mark all',
                fontSize: 13.sp,
                fontWeight: AppFontWeight.label,
                color: AppColors.primary,
              ),
            );
          }),
        ],
      ),
      bodyList: [
        Obx(() {
          switch (controller.loadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return const NotificationShimmer().asSliver;
            case LoadingState.offline:
            case LoadingState.error:
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyDataWidget(
                    message:
                        'Failed to load notifications. Please try again.',
                    onRefresh: controller.refresh,
                  ),
                ),
              );
            case LoadingState.loaded:
              if (controller.notifications.isEmpty) {
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyDataWidget(
                      message: 'No notifications yet',
                      onRefresh: controller.refresh,
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                sliver: SliverList.separated(
                  itemCount: controller.notifications.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return NotificationCardWidget(
                      notification: controller.notifications[index],
                    );
                  },
                ),
              );
          }
        }),
        PaginationLoaderSliver(controller: controller),
        SizedBox(height: 120.h).asSliver,
      ],
    );
  }
}
