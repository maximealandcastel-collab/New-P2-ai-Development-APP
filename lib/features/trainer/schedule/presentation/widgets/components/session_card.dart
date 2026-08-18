import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/entities/session_entity.dart';

/// Session Card Component
/// Displays a single session with client info and actions
class SessionCard extends StatelessWidget {
  final SessionEntity session;
  final VoidCallback? onTap;
  final VoidCallback? onStartCall;
  final VoidCallback? onMessage;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.onStartCall,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: session.isVirtual ? onTap : null,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date column
            SizedBox(
              width: 52.w,
              child: SessionDateColumn(
                shortDate: session.shortDateLabel,
                month: session.monthLabel,
                time: session.time,
              ),
            ),
            SizedBox(width: 10.w),

            // Card content
            Expanded(
              child: Container(
                padding: EdgeInsets.all(14.w),
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
                    Text(
                      session.sessionTitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Client:  ${session.clientName}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    if (session.isVirtual)
                      OutlineActionBtn(
                        icon: Icons.phone_outlined,
                        label: 'Start call',
                        onTap: onStartCall ?? () {},
                      )
                    else ...[
                      if (session.aiNote != null)
                        AiNoteBox(note: session.aiNote!),
                      SizedBox(height: 10.h),
                      OutlineActionBtn(
                        icon: Icons.chat_bubble_outline,
                        label: 'Message',
                        onTap: onMessage ?? () {},
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Session Date Column Component
class SessionDateColumn extends StatelessWidget {
  final String shortDate;
  final String month;
  final String time;

  const SessionDateColumn({
    super.key,
    required this.shortDate,
    required this.month,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shortDate,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        Text(
          month,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          time,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}

/// AI Note Box Component
class AiNoteBox extends StatelessWidget {
  final String note;

  const AiNoteBox({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 12.sp, color: Colors.black54),
              SizedBox(width: 5.w),
              Text(
                'AI Recommendation',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            note,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Outline Action Button Component
class OutlineActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const OutlineActionBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 38.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15.sp, color: Colors.black87),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
