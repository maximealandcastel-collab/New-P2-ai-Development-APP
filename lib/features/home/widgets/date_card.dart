import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DateCard extends StatelessWidget {
  const DateCard({super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48.w,
        height: 74.h,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: 8.h,horizontal: 4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(text:
              DateFormat('E').format(date),
                fontSize: 12.sp,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: 36.w,
                height: 36.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isToday && !isSelected)
                      CustomPaint(
                        size:  Size(36.w, 36.h),
                        painter: _DashedRingPainter(color: AppColors.primary),
                      )
                    else
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 1.0, end: 0.8),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, _) {
                          return CircularProgressIndicator(
                            value: value,
                            backgroundColor: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                            color: isSelected ? Colors.white : Colors.black,
                            strokeWidth: 4.r,
                          );
                        },
                      ),
                    CustomText(text:
                    '${date.day}',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
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