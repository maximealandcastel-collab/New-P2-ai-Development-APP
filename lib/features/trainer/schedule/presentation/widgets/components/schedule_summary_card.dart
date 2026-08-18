import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Schedule Summary Card Component
/// Displays session statistics (sessions today, need attention)
class ScheduleSummaryCard extends StatelessWidget {
  final int sessionToday;
  final int needAttention;
  final VoidCallback? onTap;

  const ScheduleSummaryCard({
    super.key,
    required this.sessionToday,
    required this.needAttention,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule summary',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: SummaryStatCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Session today',
                  value: sessionToday,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SummaryStatCard(
                  icon: Icons.assignment_late_outlined,
                  label: 'Need Attention',
                  value: needAttention,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Summary Stat Card Component
/// Individual stat card for schedule summary
class SummaryStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final VoidCallback? onTap;

  const SummaryStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20.sp, color: Colors.black54),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
