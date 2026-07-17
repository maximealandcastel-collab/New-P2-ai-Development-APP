import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/reels/presentation/controllers/reel_controller.dart';

/// Center play/pause affordance with a short scale animation on toggle.
class ReelPlayPauseOverlay extends StatefulWidget {
  const ReelPlayPauseOverlay({
    super.key,
    required this.reelController,
    required this.index,
  });

  final ReelController reelController;
  final int index;

  @override
  State<ReelPlayPauseOverlay> createState() => _ReelPlayPauseOverlayState();
}

class _ReelPlayPauseOverlayState extends State<ReelPlayPauseOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 0.75, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await widget.reelController.togglePlayback();
    if (!mounted) return;
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = widget.reelController.isActiveIndex(widget.index);
      if (!isActive) return const SizedBox.shrink();

      final isPlaying = widget.reelController.isPlaying.value;
      final showPauseIcon = !isPlaying;

      return GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showPauseIcon)
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.textPrimary,
                      size: 36.r,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
