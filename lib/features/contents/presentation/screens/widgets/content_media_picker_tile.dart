import 'dart:io';

import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentMediaPickerTile extends StatelessWidget {
  const ContentMediaPickerTile({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.fileName,
    this.localImagePath,
    this.remoteImageUrl,
    this.isVideo = false,
  });

  final String label;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final String? fileName;
  final String? localImagePath;
  final String? remoteImageUrl;
  final bool isVideo;

  static const double _previewHeight = 200;

  @override
  Widget build(BuildContext context) {
    final hasLocalPreview =
        localImagePath != null && localImagePath!.isNotEmpty;
    final hasRemotePreview =
        remoteImageUrl != null && remoteImageUrl!.isNotEmpty;
    final hasPreview = hasLocalPreview || hasRemotePreview;
    final hasSelection = fileName != null && fileName!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          fontSize: 14.sp,
          fontWeight: AppFontWeight.label,
          bottom: 8.h,
        ),
        CustomContainer(
          onTap: onTap,
          radiusAll: 14.r,
          color: Colors.white,
          bordersColor: AppColors.secondary,
          borderWidth: 1,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              height: _previewHeight.h,
              width: double.infinity,
              child: hasSelection
                  ? _buildSelectedPreview(
                      hasPreview: hasPreview,
                      hasLocalPreview: hasLocalPreview,
                      hasRemotePreview: hasRemotePreview,
                    )
                  : _buildEmptyPreview(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPreview() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomContainer(
            radiusAll: 999,
            paddingAll: 18.r,
            color: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(icon, color: AppColors.primary, size: 36.sp),
          ),
          SizedBox(height: 12.h),
          CustomText(
            text: hint,
            fontSize: 14.sp,
            fontWeight: AppFontWeight.label,
            color: AppColors.textSecondary,
          ),
          CustomText(
            top: 4.h,
            text: isVideo ? 'Tap to choose video file' : 'Tap to choose image',
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPreview({
    required bool hasPreview,
    required bool hasLocalPreview,
    required bool hasRemotePreview,
  }) {
    if (isVideo) {
      return _buildVideoPreview(
        hasPreview: hasPreview,
        hasLocalPreview: hasLocalPreview,
        hasRemotePreview: hasRemotePreview,
      );
    }

    return _buildImagePreview(
      hasLocalPreview: hasLocalPreview,
      hasRemotePreview: hasRemotePreview,
    );
  }

  Widget _buildVideoPreview({
    required bool hasPreview,
    required bool hasLocalPreview,
    required bool hasRemotePreview,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasPreview)
          _buildPreviewImage(
            hasLocalPreview: hasLocalPreview,
            hasRemotePreview: hasRemotePreview,
          )
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.textPrimary.withValues(alpha: 0.85),
                  AppColors.textPrimary.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
        if (hasPreview)
          Container(
            color: Colors.black.withValues(alpha: 0.35),
          ),
        Center(child: _buildPlayIcon()),
        Positioned(
          left: 12.w,
          right: 12.w,
          bottom: 12.h,
          child: _buildFileNameChip(),
        ),
        Positioned(
          top: 12.h,
          right: 12.w,
          child: _buildChangeBadge(),
        ),
      ],
    );
  }

  Widget _buildImagePreview({
    required bool hasLocalPreview,
    required bool hasRemotePreview,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildPreviewImage(
          hasLocalPreview: hasLocalPreview,
          hasRemotePreview: hasRemotePreview,
        ),
        Positioned(
          top: 12.h,
          right: 12.w,
          child: _buildChangeBadge(),
        ),
      ],
    );
  }

  Widget _buildPreviewImage({
    required bool hasLocalPreview,
    required bool hasRemotePreview,
  }) {
    if (hasLocalPreview) {
      return Image.file(
        File(localImagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return CustomNetworkImage(
      imageUrl: remoteImageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildPlayIcon() {
    return Container(
      width: 64.r,
      height: 64.r,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: AppColors.primary,
        size: 40.sp,
      ),
    );
  }

  Widget _buildFileNameChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.videocam_outlined, color: Colors.white, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: CustomText(
              text: fileName ?? '',
              fontSize: 12.sp,
              fontWeight: AppFontWeight.label,
              color: Colors.white,
              maxline: 1,
              textOverflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.upload_file, color: AppColors.primary, size: 16.sp),
          SizedBox(width: 4.w),
          CustomText(
            text: 'Change',
            fontSize: 12.sp,
            fontWeight: AppFontWeight.label,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
