import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

/// Stub inbox screen — Stream Chat integration pending (messaging task).
class TrainerInboxScreen extends StatelessWidget {
  const TrainerInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: CustomText(
          text: 'Messages',
          fontSize: 18.sp,
          fontWeight: AppFontWeight.label,
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 64.sp, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            CustomText(
              text: 'Messaging coming soon',
              fontSize: 18.sp,
              fontWeight: AppFontWeight.label,
              color: Colors.grey.shade600,
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: 'Your client conversations\nwill appear here.',
              fontSize: 14.sp,
              color: Colors.grey.shade400,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
