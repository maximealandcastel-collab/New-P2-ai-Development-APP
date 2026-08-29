import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

/// Args passed via [Get.to] or [Get.toNamed] when opening the chat screen.
class ChatScreenArgs {
  const ChatScreenArgs({
    required this.displayName,
    this.subtitle = 'subscriber',
    this.isAnamEnabled = false,
    this.trainerId,
    this.channelId,
    this.channelType = 'messaging',
    this.otherUserId,
    this.otherUserImage,
  });

  final String displayName;
  final String subtitle;
  final bool isAnamEnabled;
  final String? trainerId;
  final String? channelId;
  final String channelType;
  final String? otherUserId;
  final String? otherUserImage;
}

/// Stub chat screen — Stream Chat integration pending (messaging task).
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments is ChatScreenArgs
        ? Get.arguments as ChatScreenArgs
        : const ChatScreenArgs(displayName: 'Chat');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: args.displayName,
              fontSize: 16.sp,
              fontWeight: AppFontWeight.label,
              color: Colors.black,
            ),
            CustomText(
              text: args.subtitle,
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64.sp, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            CustomText(
              text: 'Messaging coming soon',
              fontSize: 18.sp,
              fontWeight: AppFontWeight.label,
              color: Colors.grey.shade600,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: 'Real-time chat with your clients\nwill be available shortly.',
              fontSize: 14.sp,
              color: Colors.grey.shade400,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
