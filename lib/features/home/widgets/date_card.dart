import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DateCard extends StatelessWidget {
  const DateCard({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
    this.progress = 0.0,
    this.isDisabled = false,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;
  final double progress;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final activeColor = isSelected ? AppColors.primary : Colors.white;
    final backgroundColor = isDisabled ? Colors.white.withValues(alpha: 0.4) : activeColor;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52.w,
        height: 84.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
          border: isDisabled 
              ? Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1.r)
              : null,
          boxShadow: !isDisabled && !isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4.r,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: DateFormat('E').format(date),
                fontSize: 12.sp,
                color: isSelected
                    ? Colors.white
                    : (isDisabled ? AppColors.textSecondary.withValues(alpha: 0.4) : AppColors.textSecondary),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: 36.w,
                height: 36.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isDisabled && isToday && !isSelected)
                      CustomPaint(
                        size: Size(36.w, 36.h),
                        painter: _DashedRingPainter(color: AppColors.primary),
                      )
                    else
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: isDisabled ? 0.0 : progress),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, _) {
                          return CircularProgressIndicator(
                            value: value,
                            backgroundColor: isSelected
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.05),
                            color: isSelected
                                ? Colors.white
                                : (isDisabled ? AppColors.primary.withValues(alpha: 0.4) : AppColors.primary),
                            strokeWidth: 3.5.r,
                          );
                        },
                      ),
                    CustomText(
                      text: '${date.day}',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDisabled ? Colors.black.withValues(alpha: 0.3) : Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  _DashedRingPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    const dashCount = 16;
    const gapFraction = 0.4;
    final sweepPerDash = (2 * 3.141592653589793) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * sweepPerDash;
      canvas.drawArc(
        rect,
        startAngle,
        sweepPerDash * (1 - gapFraction),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
