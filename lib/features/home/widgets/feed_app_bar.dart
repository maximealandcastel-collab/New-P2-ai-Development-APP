import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/common/notification/presentation/screen/notification_screen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';
import 'package:pler_to_pler_app/widgets/custom_network_image.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

class FeedAppBar extends StatelessWidget {
  const FeedAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              imageUrl:
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textAlign: TextAlign.start,
                  maxline: 1,
                  textOverflow: TextOverflow.ellipsis,
                  text: 'Hi Ethen!',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
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
              width: 48.w,
              height: 48.h,
              color: Colors.white,
              shape: BoxShape.circle,
              child: Assets.icons.notification.svg(),
            ),
          ),
        ],
      ),
    );
  }
}
