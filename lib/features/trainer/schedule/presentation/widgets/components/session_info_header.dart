import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Session Info Header Component
/// Displays session title, date, and time
class SessionInfoHeader extends StatelessWidget {
  final String title;
  final String dateLabel;
  final String time;
  final String? sessionTag;

  const SessionInfoHeader({
    super.key,
    required this.title,
    required this.dateLabel,
    required this.time,
    this.sessionTag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            height: 1.3,
          ),
        ),
        SizedBox(height: 16.h),

        // Date + Time row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Date',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (sessionTag != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.h,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF7A00),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          sessionTag!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Time',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
