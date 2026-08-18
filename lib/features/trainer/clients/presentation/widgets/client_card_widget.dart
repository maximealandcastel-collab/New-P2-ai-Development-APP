import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/custom_container.dart';
import '../../../../../widgets/custom_image_avatar.dart';
import '../../../../../widgets/custom_text.dart';

class ClientCardWidget extends StatelessWidget {
  final Map<String, String> client;
  final bool isPending;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onChat;

  const ClientCardWidget({
    super.key,
    required this.client,
    required this.isPending,
    this.onAccept,
    this.onReject,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 16.r,
      color: Colors.white,
      paddingAll: 16.r,
      marginBottom: 12.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomImageAvatar(image: 'https://picsum.photos/300', radius: 22.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: client['name'] ?? '',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    CustomText(
                      text: isPending
                          ? (client['pendingSubtitle'] ?? 'Pending client')
                          : (client['subtitle'] ?? ''),
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onChat,
                child: CustomContainer(
                  paddingAll: 10.r,
                  radiusAll: 100.r,
                  color: Colors.black.withOpacity(0.04),
                  child: Icon(Icons.chat_bubble, size: 18.r, color: Colors.black),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          CustomText(
            text: 'Pain/Condition',
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            bottom: 4.h,
          ),
          CustomText(
            text: client['condition'] ?? '',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            bottom: 12.h,
          ),
          if (!isPending)
            _buildAiInsight(client['insight'] ?? '')
          else ...[
            _buildPendingMessage(client['message'] ?? ''),
            SizedBox(height: 16.h),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildAiInsight(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return CustomContainer(
      paddingAll: 12.r,
      radiusAll: 12.r,
      color: const Color(0xFFD45D4C),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 16.r),
          SizedBox(width: 8.w),
          Expanded(
            child: CustomText(
              text: text,
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingMessage(String message) {
    return CustomContainer(
      paddingAll: 12.r,
      radiusAll: 12.r,
      color: Colors.black.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message, size: 14.r, color: Colors.black54),
              CustomText(text: 'Message', fontSize: 13.sp, left: 6.w, fontWeight: FontWeight.w700),
            ],
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: message,
            fontSize: 13.sp,
            color: Colors.black87,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            onPressed: onAccept,
            label: 'Accept',
            height: 44.h,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            bordersColor: Colors.black.withOpacity(0.1),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomButton(
            onPressed: onReject,
            label: 'Reject',
            height: 44.h,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            bordersColor: Colors.black.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}