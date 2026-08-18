import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Empty Schedule Component
/// Displays when no sessions are scheduled for the selected day
class EmptySchedule extends StatelessWidget {
  final String message;
  final IconData? icon;

  const EmptySchedule({
    super.key,
    this.message = 'No scheduled appointment to attend',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Container(
              width: 70.w,
              height: 70.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.event_busy_outlined,
                size: 30.sp,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
