import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/notification/presentation/controllers/notification_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';
import 'package:pler_to_pler_app/widgets/custom_network_image.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

class FeedAppBarSliver extends StatelessWidget {
  const FeedAppBarSliver({super.key, this.bottom, this.pinned = false});

  final PreferredSizeWidget? bottom;
  final bool pinned;

  /// Role from ProfileController — the same source lib/widgets/app_bar.dart
  /// uses, so the two app bars finally agree about who is looking at them.
  ///
  /// This used to route on `LoginController.to.isTrainer()`, which is
  /// `getRole() == 'trainer'` and therefore **excludes admins**. An admin
  /// tapping the avatar here landed on the subscriber profile, while the same
  /// tap on the dashboard bar took them to the trainer one. `isTrainer()`
  /// itself is left alone on purpose: anam_call_screen.dart uses it as a
  /// permission gate where "trainer, not admin" is the intended meaning.
  bool _isTrainer(ProfileController c) {
    final role = (c.userData?.role ?? '').toLowerCase();
    return role == 'trainer' || role == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: pinned,
      floating: true,
      snap: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6),
      scrolledUnderElevation: 10,
      shadowColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.1),
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.1),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            MediaQuery.of(context).padding.top + 4.h,
            16.w,
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final user = controller.userData;
                return GestureDetector(
                  onTap: () {
                    if (_isTrainer(controller)) {
                      Get.toNamed(AppRoute.profileScreen);
                    } else {
                      Get.toNamed(AppRoute.userProfileScreen);
                    }
                  },
                  child: CustomNetworkImage(
                    key: ValueKey('${user?.profilePicture}_${user?.updatedAt}'),
                    height: 48.r,
                    width: 48.r,
                    boxShape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.48),
                    ),
                    imageFile: controller.selectedProfilePicture,
                    imageUrl: user?.profilePicture,
                  ),
                );
              }),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      return CustomText(
                        textAlign: TextAlign.start,
                        maxline: 1,
                        textOverflow: TextOverflow.ellipsis,
                        text: 'Hi ${controller.userData?.firstName?.isNotEmpty == true ? controller.userData!.firstName! : controller.userData?.preferredName?.isNotEmpty == true ? controller.userData!.preferredName! : "there"}!',
                        fontSize: 18.sp,
                        fontWeight: AppFontWeight.emphasis,
                      );
                    }),
                    // Was a hardcoded 'Let’s Manage your  users' — note the
                    // doubled space — shown to everyone. This bar is on the
                    // History and Trainer tabs, so plain subscribers were
                    // being told to manage users they do not have. Role-aware
                    // now, and worded to match lib/widgets/app_bar.dart.
                    Obx(() {
                      return CustomText(
                        top: 2.h,
                        text: _isTrainer(controller)
                            ? 'Let’s manage your clients'
                            : 'Let’s crush today’s workout',
                        textAlign: TextAlign.start,
                        maxline: 1,
                        textOverflow: TextOverflow.ellipsis,
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      );
                    }),
                  ],
                ),
              ),

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.toNamed(AppRoute.notificationsScreen),
                child: Obx(() {
                  final unread =
                      NotificationController.to.unreadCount;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomContainer(
                        paddingAll: 10.r,
                        color: Colors.white,
                        shape: BoxShape.circle,
                        child: Assets.icons.notification.svg(
                          height: 24.h,
                          width: 24.w,
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: -2.h,
                          right: -2.w,
                          child: CustomContainer(
                            paddingHorizontal: unread > 9 ? 5.w : 0,
                            height: 16.r,
                            width: unread > 9 ? null : 16.r,
                            radiusAll: 10.r,
                            color: AppColors.error,
                            alignment: Alignment.center,
                            child: CustomText(
                              text: unread > 99 ? '99+' : '$unread',
                              fontSize: 9.sp,
                              fontWeight: AppFontWeight.section,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      bottom: bottom,
    );
  }
}
