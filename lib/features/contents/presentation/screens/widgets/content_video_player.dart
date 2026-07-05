import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_details_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_player_sheet.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentVideoPlayer extends StatelessWidget {
  const ContentVideoPlayer({
    super.key,
    required this.controller,
    this.poster,
    this.borderRadius,
    this.showActions = true,
  });

  final ContentDetailsController controller;
  final Widget? poster;
  final BorderRadius? borderRadius;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final controlsTheme = MaterialVideoControlsThemeData(
      buttonBarButtonColor: AppColors.primary,
      backdropColor: AppColors.backgroundDark.withValues(alpha: 0.75),
      seekBarAlignment: Alignment.bottomCenter,
      buttonBarHeight: 44.h,
    );

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: MaterialVideoControlsTheme(
          normal: controlsTheme,
          fullscreen: controlsTheme.copyWith(buttonBarHeight: 52.h),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ?poster,
              Video(

                controller: controller.videoController,
                controls: MaterialVideoControls,
                //fill: AppColors.backgroundLight,
                fit: BoxFit.contain,
                subtitleViewConfiguration: SubtitleViewConfiguration(
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  //padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 72.h),
                  textAlign: TextAlign.center,
                ),
              ),
              Obx(() {
                final isLoading = controller.isLoadingMedia.value;
                final error = controller.mediaError.value;

                if (!isLoading && error.isEmpty) {
                  return const SizedBox.shrink();
                }

                return ColoredBox(
                  color: AppColors.backgroundDark.withValues(alpha: 0.6),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(color: AppColors.primary)
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: CustomText(
                              text: error,
                              color: AppColors.textWhite,
                              fontSize: 14.sp,
                            ),
                          ),
                  ),
                );
              }),
              if (showActions)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: ContentPlayerActionBar(controller: controller),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentPlayerActionBar extends StatelessWidget {
  const ContentPlayerActionBar({super.key, required this.controller});

  final ContentDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SpeedButton(controller: controller),
          _ActionButton(
            icon: Icons.subtitles_outlined,
            onTap: () => ContentPlayerSheet.showSubtitles(context, controller),
          ),
          Obx(() {
            if (!controller.pipAvailable.value) return const SizedBox.shrink();
            return _ActionButton(
              icon: Icons.picture_in_picture_alt_outlined,
              onTap: controller.enterPictureInPicture,
            );
          }),
        ],
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.controller});

  final ContentDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _ActionButton(
        icon: Icons.speed_rounded,
        label: '${controller.playbackSpeed.value}x',
        onTap: () => ContentPlayerSheet.showSpeed(context, controller),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textWhite, size: 18.r),
            if (label != null) ...[
              SizedBox(width: 4.w),
              Text(
                label!,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
