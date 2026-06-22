import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/common/notification/presentation/screen/notification_screen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';
import 'package:pler_to_pler_app/widgets/custom_network_image.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

class FeedAppBarSliver extends StatelessWidget {
  const FeedAppBarSliver({super.key, this.bottom,  this.pinned = false});

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
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(background:Padding(
        padding: EdgeInsets.fromLTRB(
          16.w,
          MediaQuery.of(context).padding.top + 4.h,
          16.w,
          0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => ProfileScreen());
              },
              child: CustomNetworkImage(
                height: 48.r,
                width: 48.r,
                boxShape: BoxShape.circle,
                border: Border.all(color: Colors.black.withValues(alpha: 0.48)),
                imageUrl: controller.userData?.profilePicture,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                          () {
                        return CustomText(
                          textAlign: TextAlign.start,
                          maxline: 1,
                          textOverflow: TextOverflow.ellipsis,
                          text: 'Hi ${controller.userData?.firstName}!',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        );
                      }
                  ),
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
              onTap: () {
                Get.to(() => NotificationsScreen());
              },
              child: CustomContainer(
                paddingAll: 10.r,
                color: Colors.white,
                shape: BoxShape.circle,
                child: Assets.icons.notification.svg(height: 24.h,width: 24.w),
              ),
            ),
          ],
        ),
      )),
      bottom: bottom,
    );
  }
}

