import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SessionsCardWidget extends StatelessWidget {
  const SessionsCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginTop: 8.h,
      radiusAll: 12.r,
      color: Colors.black.withOpacity(0.08),
      paddingHorizontal: 12.w,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: CustomText(
          textAlign: TextAlign.start,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          text: 'John Adams',
        ),
        subtitle: CustomText(
          textAlign: TextAlign.start,
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          text: 'Rehab session 10:00 AM',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.calender.svg(height: 32.r, width: 32.r),
          ],
        ),
      ),
    );
  }
}
