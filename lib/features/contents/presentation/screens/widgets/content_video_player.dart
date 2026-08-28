import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_details_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_player_sheet.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:video_player/video_player.dart';

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
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: AspectRatio(
        aspectRatio: 1,
        child: Obx(() {
          final isLoading = controller.isLoadingMedia.value;
          final error = controller.mediaError.value;
          final videoController = controller.videoPlayerController;
          final playerReady =
              videoController != null && controller.isVideoReady;

          return Stack(
            fit: StackFit.expand,
            children: [
              if (poster != null && !playerReady)
                poster!
              else if (poster != null)
                Opacity(opacity: 0, child: poster),
              if (playerReady)
                GestureDetector(
                  onTap: controller.togglePlayback,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: controller.aspectRatio,
                      child: VideoPlayer(videoController),
                    ),
                  ),
                ),
              if (playerReady) _buildControlsOverlay(context),
              if (isLoading)
                ColoredBox(
                  color: AppColors.backgroundDark.withValues(alpha: 0.55),
                  child: const Center(child: CustomLoader()),
                ),
              if (!isLoading && error.isNotEmpty) _buildErrorOverlay(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildControlsOverlay(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Obx(() {
          if (controller.isPlaying.value) {
            return const SizedBox.shrink();
          }

          return Center(
            child: Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppColors.textWhite,
                size: 32.r,
              ),
            ),
          );
        }),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildProgressBar(),
        ),
        if (showActions)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: ContentPlayerActionBar(controller: controller),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Obx(() {
      final total = controller.duration.value;
      final current = controller.position.value;
      final maxMs = total.inMilliseconds.toDouble();
      final value = maxMs <= 0
          ? 0.0
          : current.inMilliseconds.toDouble().clamp(0.0, maxMs).toDouble();

      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.backgroundDark.withValues(alpha: 0.82),
              AppColors.backgroundDark.withValues(alpha: 0),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3.h,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.r),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 10.r),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor:
                      AppColors.textWhite.withValues(alpha: 0.25),
                  thumbColor: AppColors.primary,
                ),
                child: Slider(
                  min: 0,
                  max: maxMs <= 0 ? 1 : maxMs,
                  value: value,
                  onChanged: maxMs <= 0
                      ? null
                      : (next) => controller.seekTo(
                            Duration(milliseconds: next.round()),
                          ),
                ),
              ),
              Row(
                children: [
                  CustomText(
                    text: _formatDuration(current),
                    fontSize: 11.sp,
                    color: AppColors.textWhite,
                  ),
                  const Spacer(),
                  CustomText(
                    text: _formatDuration(total),
                    fontSize: 11.sp,
                    color: AppColors.textWhite.withValues(alpha: 0.85),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildErrorOverlay() {
    return ColoredBox(
      color: AppColors.backgroundDark.withValues(alpha: 0.72),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: controller.mediaError.value,
                color: AppColors.textWhite,
                fontSize: 14.sp,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              CustomButton(
                label: 'Retry',
                onPressed: controller.retryLoad,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
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
              CustomText(
                text: label!,
                color: AppColors.textWhite,
                fontSize: 12.sp,
                fontWeight: AppFontWeight.label,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
