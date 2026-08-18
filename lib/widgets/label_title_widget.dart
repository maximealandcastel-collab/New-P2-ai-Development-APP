import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import '../../../../widgets/widgets.dart';

class LabelTitleWidget extends StatelessWidget {
  const LabelTitleWidget({
    super.key,
    required this.title,
     this.onTap,
    this.isSeeShow = true,  this.fontWeight = FontWeight.w400,
  });

  final String title;
  final VoidCallback? onTap;
  final bool isSeeShow;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical: 10.h),
      child: Row(
        children: [
          CustomText(
            text: title,
            fontWeight: fontWeight,
            fontSize: 16.sp,
          ),
          Spacer(),
          if (isSeeShow)
            GestureDetector(
              onTap: onTap,
              child: CustomText(text: 'See all', fontSize: 14.sp,color: AppColors.textPrimary,),
            ),

        ],
      ),
    );
  }
}
