import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({super.key});


  @override
  Widget build(BuildContext context) {
    return CustomContainer(
     paddingBottom: 16.h,
      border: Border(
          bottom: BorderSide(
              color: AppColors.secondary,
              width: 0.5
          )
      ),
      child: Row(
        children: [
          CustomNetworkImage(
            borderRadius: 8.r,
            width: 96.w,
            height: 74.h,
            imageUrl: '',
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                    maxline: 2,
                    textOverflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.start,
                    text: 'Ultimate Cardio Blast: Feel the Burn!'),
                CustomText(
                    top: 2.h,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.start,
                    text: 'uploaded 25 min ago'),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        fontWeight: FontWeight.w400,
                        radius: 8.r,
                        fontSize: 12.sp,
                        height: 26.h,
                        onPressed: (){},label: 'Edit',),
                    ),
                    SizedBox(width: 8.w,),
                    Expanded(
                      child: CustomButton(
                        fontWeight: FontWeight.w400,
                        backgroundColor: Colors.white,
                        bordersColor: AppColors.error,
                        foregroundColor: AppColors.error,
                        radius: 8.r,
                        fontSize: 12.sp,
                        height: 26.h,
                        onPressed: (){},label: 'Delete',),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
