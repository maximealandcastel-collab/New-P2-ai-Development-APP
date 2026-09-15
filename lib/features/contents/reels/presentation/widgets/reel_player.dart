import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_thumbnail_placeholder.dart';
import 'package:pler_to_pler_app/features/contents/reels/presentation/controllers/reel_controller.dart';
import 'package:pler_to_pler_app/features/contents/reels/presentation/widgets/reel_play_pause_overlay.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReelPlayer extends StatelessWidget {
  const ReelPlayer({
    super.key,
    required this.content,
    required this.index,
    required this.reelController,
    required this.contents,
  });

  final ContentModel content;
  final int index;
  final ReelController reelController;
  final List<ContentModel> contents;

  static const _background = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('reel_${content.id ?? index}'),
      onVisibilityChanged: (info) => reelController.onVisibilityChanged(
        index: index,
        info: info,
        contents: contents,
      ),
      child: ColoredBox(
        color: _background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Obx(() {
              reelController.slotVersion.value;
              reelController.currentIndex.value;
              final isOnline =
                  Get.find<ConnectivityService>().isConnected.value;
              return _buildVideo(isOnline: isOnline);
            }),
            ReelPlayPauseOverlay(
              reelController: reelController,
              index: index,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideo({required bool isOnline}) {
    final controller = reelController.videoControllerFor(index);
    final slot = reelController.playerManager.slotFor(index);
    final isActive = reelController.isActiveIndex(index);
    final showError = slot != null &&
        slot.error.isNotEmpty &&
        !slot.isLoading &&
        controller == null;
    final showLoader = isOnline &&
        isActive &&
        !showError &&
        controller == null &&
        (slot == null || slot.isLoading || !slot.isReady);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller == null) _buildPoster(),
        if (controller != null)
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio == 0
                  ? 9 / 16
                  : controller.value.aspectRatio,
              child: VideoPlayer(
                controller,
                key: ValueKey(slot?.sourceKey ?? index),
              ),
            ),
          ),
        if (showLoader)
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        if (showError) _buildError(slot.error),
      ],
    );
  }

  Widget _buildPoster() {
    final thumbnailUrl = ContentMediaResolver.resolveThumbnailUrl(content);

    return Stack(
      fit: StackFit.expand,
      children: [
        ContentThumbnailPlaceholder(
          title: content.title,
          showTitle: false,
        ),
        if (thumbnailUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => const SizedBox.shrink(),
            errorWidget: (_, _, _) => const SizedBox.shrink(),
          ),
      ],
    );
  }

  Widget _buildError(String message) {
    return ColoredBox(
      color: _background.withValues(alpha: 0.72),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: message,
                color: AppColors.textWhite,
                fontSize: 14.sp,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              CustomButton(
                label: 'Retry',
                onPressed: () =>
                    reelController.retryAt(index, contents),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
