import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TransationHistoryWidget extends StatelessWidget {
  const TransationHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginTop: 8.h,
      radiusAll: 16.r,
      color: Colors.white,
      paddingHorizontal: 12.w,
      child: ListTile(
        leading: CustomContainer(
          bordersColor: Colors.black.withOpacity(0.16),
          color: Colors.black.withOpacity(0.04),
          radiusAll: 16.r,
          width: 40.w,
          height: 40.h,
          child: Icon(Icons.arrow_downward,color: AppColors.textPrimary,size: 20.r,),
        ),

        contentPadding: EdgeInsets.zero,
        title: CustomText(
          textAlign: TextAlign.start,
          fontWeight: FontWeight.w600,
          text: 'Received money',
          maxline: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        subtitle: CustomText(
          textAlign: TextAlign.start,
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          text: '5 hour ago - 8:30 AM',
        ),
        trailing: CustomText(text: '\$589.29',fontWeight: FontWeight.w600,color: AppColors.success),
      ),
    );
  }
}
