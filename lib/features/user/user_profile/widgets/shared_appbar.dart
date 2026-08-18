import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED APP BAR
// ═══════════════════════════════════════════════════════════════════════════════

class SharedAppBar extends StatelessWidget {
  final String title;

  const SharedAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 34.w, height: 34.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Icon(Icons.chevron_left, size: 20.sp, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.black),
            ),
          ),
          SizedBox(width: 34.w),
        ],
      ),
    );
  }
}