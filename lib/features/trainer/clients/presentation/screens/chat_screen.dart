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

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _attemptSend() {
    if (_messageController.text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Message delivery is not connected yet. Your message was not sent.',
        ),
      ),
    );
  }

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
        title: Row(
          children: [
            CircleAvatar(
              radius: 19.r,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: CustomText(
                text: args.displayName.trim().isEmpty
                    ? '?'
                    : args.displayName.trim()[0].toUpperCase(),
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: args.displayName,
                    textAlign: TextAlign.start,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  CustomText(
                    text: args.subtitle,
                    textAlign: TextAlign.start,
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 36.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 52.sp,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 14.h),
                      CustomText(
                        text: 'No messages yet',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(height: 6.h),
                      CustomText(
                        text:
                            'Your conversation with ${args.displayName} will appear here.',
                        fontSize: 13.sp,
                        color: Colors.grey.shade500,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFECECEC))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: Colors.grey.shade600),
                  ),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Message ${args.displayName}...',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade400,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F3F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 11.h,
                        ),
                      ),
                      onSubmitted: (_) => _attemptSend(),
                    ),
                  ),
                  SizedBox(width: 9.w),
                  GestureDetector(
                    onTap: _attemptSend,
                    child: Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
