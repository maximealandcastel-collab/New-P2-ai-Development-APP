import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/notification/data/models/notification_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class NotificationCardWidget extends StatelessWidget {
  const NotificationCardWidget({
    super.key,
    required this.notification,
    this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      paddingAll: 16.r,
      radiusAll: 16.r,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontFamily: 'Poppins',
                    ),
                    children: [
                      TextSpan(
                        text: '${notification.title} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '${notification.action} ',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (notification.hasTarget)
                        TextSpan(
                          text: '${notification.target} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      TextSpan(
                        text: '• ${notification.date}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (notification.hasPreview) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        width: 2.w,
                        height: 20.h,
                        color: Colors.black12,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomText(
                          text: notification.preview!,
                          fontSize: 13.sp,
                          color: Colors.grey,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (notification.hasImage) ...[
            SizedBox(width: 12.w),
            CustomNetworkImage(
              imageUrl: notification.imageUrl,
              width: 50.w,
              height: 50.w,
              borderRadius: 8.r,
              fit: BoxFit.cover,
            ),
          ],
        ],
      ),
    );
  }
}
