import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/reels/core/reel_colors.dart';
import 'package:pler_to_pler_app/features/contents/reels/core/reel_video_slot.dart';
import 'package:pler_to_pler_app/features/contents/reels/presentation/controllers/reel_controller.dart';
import 'package:pler_to_pler_app/features/contents/reels/presentation/widgets/reel_play_pause_overlay.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Reusable full-screen reel player with caching, visibility autoplay, and overlays.
class ReelPlayer extends StatefulWidget {
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

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> {
  ReelVideoSlot? _watchedSlot;

  @override
  void initState() {
    super.initState();
    widget.reelController.playerManager.addListener(_onManagerChanged);
    _bindSlotListener();
  }

  @override
  void didUpdateWidget(covariant ReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index ||
        oldWidget.reelController != widget.reelController) {
      _bindSlotListener();
    }
  }

  @override
  void dispose() {
    _watchedSlot?.removeListener(_onSlotChanged);
    widget.reelController.playerManager.removeListener(_onManagerChanged);
    super.dispose();
  }

  void _onManagerChanged() {
    _bindSlotListener();
    if (mounted) setState(() {});
  }

  void _bindSlotListener() {
    final slot = widget.reelController.playerManager.slotFor(widget.index);
    if (identical(slot, _watchedSlot)) return;

    _watchedSlot?.removeListener(_onSlotChanged);
    _watchedSlot = slot;
    _watchedSlot?.addListener(_onSlotChanged);
  }

  void _onSlotChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('reel_visibility_${widget.content.id ?? widget.index}'),
      onVisibilityChanged: (info) {
        widget.reelController.onVisibilityChanged(
          index: widget.index,
          info: info,
          contents: widget.contents,
        );
      },
      child: RepaintBoundary(
        child: ColoredBox(
          color: ReelColors.background,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildMediaLayer(),
              ReelPlayPauseOverlay(
                reelController: widget.reelController,
                index: widget.index,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaLayer() {
    final slot = widget.reelController.playerManager.slotFor(widget.index);
    final videoController = slot?.controller;
    final isReady = slot?.isInitialized ?? false;
    final hasError = slot?.error.isNotEmpty ?? false;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (videoController != null && isReady)
          _buildVideo(videoController)
        else
          const ColoredBox(color: ReelColors.background),
        if (hasError && slot != null) _buildErrorState(slot),
      ],
    );
  }

  Widget _buildVideo(VideoPlayerController controller) {
    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio == 0
            ? 9 / 16
            : controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildErrorState(ReelVideoSlot slot) {
    return ColoredBox(
      color: ReelColors.background,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: slot.error,
                color: AppColors.textWhite,
                fontSize: 14.sp,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              CustomButton(
                label: 'Retry',
                onPressed: () =>
                    widget.reelController.retryAt(widget.index, widget.contents),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
