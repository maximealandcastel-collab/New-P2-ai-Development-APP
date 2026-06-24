import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginBottom: isLast ? 0 : 8.h,
      color: Colors.black.withValues(alpha: 0.05),
      width: double.infinity,
      paddingHorizontal: 16.w,
      paddingVertical: 12.h,
      radiusAll: 12.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            fontSize: 12.sp,
            color: Colors.grey,
            bottom: 4.h,
          ),
          CustomText(
            text: value,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            maxline: 3,
          ),
        ],
      ),
    );
  }
}
