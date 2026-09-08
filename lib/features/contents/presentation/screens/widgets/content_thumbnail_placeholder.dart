import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentThumbnailPlaceholder extends StatelessWidget {
  const ContentThumbnailPlaceholder({
    super.key,
    this.title,
    this.showTitle = true,
  });

  final String? title;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.r,
                height: 72.r,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                  size: 40.r,
                ),
              ),
              if (showTitle && (title?.trim().isNotEmpty ?? false)) ...[
                SizedBox(height: 16.h),
                CustomText(
                  text: title!.trim(),
                  color: AppColors.textWhite.withValues(alpha: 0.85),
                  fontSize: 16.sp,
                  fontWeight: AppFontWeight.label,
                  maxline: 2,
                  textOverflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
