import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PairingPulseIndicator extends StatefulWidget {
  const PairingPulseIndicator({super.key});

  @override
  State<PairingPulseIndicator> createState() => _PairingPulseIndicatorState();
}

class _PairingPulseIndicatorState extends State<PairingPulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.r,
      width: 120.r,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _PulseRing(progress: _controller.value, scale: 1.0),
              _PulseRing(
                progress: (_controller.value + 0.33) % 1.0,
                scale: 0.82,
              ),
              _PulseRing(
                progress: (_controller.value + 0.66) % 1.0,
                scale: 0.64,
              ),
              child!,
            ],
          );
        },
        child: CustomContainer(
          shape: BoxShape.circle,
          paddingAll: 22.r,
          color: AppColors.primary.withValues(alpha: 0.12),
          child: Icon(
            Icons.bluetooth_searching,
            size: 36.r,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.progress, required this.scale});

  final double progress;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final opacity = (1 - progress).clamp(0.0, 1.0) * 0.35;

    return Transform.scale(
      scale: scale + progress * 0.45,
      child: Container(
        height: 120.r,
        width: 120.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: opacity),
            width: 2,
          ),
        ),
      ),
    );
  }
}
