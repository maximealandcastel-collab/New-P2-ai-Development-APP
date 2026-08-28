import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/notification/presentation/controllers/notification_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';
import 'package:pler_to_pler_app/widgets/custom_network_image.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

class FeedAppBarSliver extends StatelessWidget {
  const FeedAppBarSliver({super.key, this.bottom, this.pinned = false});

  final PreferredSizeWidget? bottom;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: pinned,
      floating: true,
      snap: true,
      backgroundColor: AppColors.backgroundLight.withValues(alpha: 0.6),
      scrolledUnderElevation: 10,
      shadowColor: AppColors.backgroundLight.withValues(alpha: 0.1),
      surfaceTintColor: AppColors.backgroundLight.withValues(alpha: 0.1),
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
                    if (LoginController.to.isTrainer()) {
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
                    CustomText(
                      top: 2.h,
                      text: 'Let’s Manage your  users',
                      textAlign: TextAlign.start,
                      maxline: 1,
                      textOverflow: TextOverflow.ellipsis,
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
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