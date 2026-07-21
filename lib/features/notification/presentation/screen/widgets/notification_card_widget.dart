import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/fonts.gen.dart';
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
      color: notification.isRead
          ? Colors.white
          : AppColors.primary.withValues(alpha: 0.06),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!notification.isRead) ...[
            Container(
              width: 8.w,
              height: 8.w,
              margin: EdgeInsets.only(top: 6.h, right: 8.w),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
          Expanded(
            child: notification.usesLegacyLayout
                ? _buildLegacyContent()
                : _buildMessageContent(),
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

  Widget _buildMessageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: notification.displayMessage,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          textAlign: TextAlign.start,
        ),
        if (notification.date.isNotEmpty) ...[
          SizedBox(height: 6.h),
          CustomText(
            text: notification.date,
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
        ],
      ],
    );
  }

  Widget _buildLegacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
              fontFamily: FontFamily.figtree,
            ),
            children: [
              TextSpan(
                text: '${notification.title} ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (notification.hasAction)
                TextSpan(
                  text: '${notification.action} ',
                  style: const TextStyle(color: Colors.grey),
                ),
              if (notification.hasTarget)
                TextSpan(
                  text: '${notification.target} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (notification.date.isNotEmpty)
                TextSpan(
                  text: '• ${notification.date}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
        ),
        if (notification.hasPreview &&
            notification.preview != notification.message) ...[
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
    );
  }
}
