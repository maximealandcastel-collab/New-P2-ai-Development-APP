import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';


class GradientRingLoader extends StatefulWidget {
  final double size;
  final double strokeWidth;

  const GradientRingLoader({
    super.key,
    this.size = 100,
    this.strokeWidth = 6,
  });

  @override
  State<GradientRingLoader> createState() => _GradientRingLoaderState();
}

class _GradientRingLoaderState extends State<GradientRingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159265,
          child: child,
        );
      },
      child: SizedBox(
        width: widget.size.w,
        height: widget.size.w,
        child: CustomPaint(
          painter: _GradientRingPainter(strokeWidth: widget.strokeWidth.w, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  final double strokeWidth;

  final Color color;

  _GradientRingPainter({required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 3.14159265 * 2,
      colors: [
        Colors.transparent,
        color,
        color,
        AppColors.secondary,
        Colors.white,
      ],
      stops: const [0.0, 0.55, 0.75, 0.9, 1.0],
      transform: const GradientRotation(-1.5708),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 3.14159265 * 2, false, paint);

    // Glow at the leading edge (near angle 0 / top after rotation)
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(rect, -0.35, 0.35, false, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) => oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
