import 'dart:io';

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

  @override
  Widget build(BuildContext context) {
    final hasLocalImage =
        !isVideo && localImagePath != null && localImagePath!.isNotEmpty;
    final hasRemoteImage =
        !isVideo && remoteImageUrl != null && remoteImageUrl!.isNotEmpty;
    final hasSelection = fileName != null && fileName!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          bottom: 8.h,
        ),
        CustomContainer(
          onTap: onTap,
          radiusAll: 14.r,
          color: Colors.white,
          bordersColor: AppColors.secondary,
          borderWidth: 1,
          width: double.infinity,
          paddingHorizontal: 14.w,
          paddingVertical: 14.h,
          child: Row(
            children: [
              _buildLeading(hasLocalImage, hasRemoteImage),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: hasSelection ? fileName! : hint,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.start,
                      color: hasSelection ? null : AppColors.textSecondary,
                    ),
                    CustomText(
                      top: 4.h,
                      text: isVideo ? 'Tap to choose video file' : 'Tap to choose image',
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              Icon(Icons.upload_file, color: AppColors.primary, size: 22.sp),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeading(bool hasLocalImage, bool hasRemoteImage) {
    if (hasLocalImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Image.file(
          File(localImagePath!),
          width: 52.r,
          height: 52.r,
          fit: BoxFit.cover,
        ),
      );
    }

    if (hasRemoteImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: CustomNetworkImage(
          imageUrl: remoteImageUrl!,
          width: 52.r,
          height: 52.r,
          fit: BoxFit.cover,
        ),
      );
    }

    return CustomContainer(
      radiusAll: 10.r,
      paddingAll: 12.r,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(icon, color: AppColors.primary, size: 24.sp),
    );
  }
}
