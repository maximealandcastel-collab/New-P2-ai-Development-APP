import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginBottom: 10.h,
      radiusAll: 16.r,
      color: Colors.white,
      paddingAll: 16.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomNetworkImage(
                height: 40.r,
                width: 40.r,
                imageUrl: '',
                boxShape: BoxShape.circle,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      textAlign: TextAlign.start,
                      textOverflow: TextOverflow.ellipsis,
                      maxline: 1,
                      text: 'Oliver Westwood',
                      fontWeight: FontWeight.w600,
                    ),
                    CustomText(
                      textAlign: TextAlign.start,
                      text: 'Pending client',
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          CustomText(
            top: 10.h,
            textAlign: TextAlign.start,
            text: 'Request at 04-07-2026',
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),

          SizedBox(height: 10.h),
          CustomContainer(
            radiusAll: 16.r,
            color: Colors.black.withValues(alpha: 0.08),
            paddingAll: 10.r,
            child: Column(
              children: [
                Row(
                  children: [
                    Assets.icons.note.svg(),
                    CustomText(
                      left: 6.w,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.start,
                      text: 'Note',
                      fontSize: 12.sp,
                    ),
                  ],
                ),
                CustomText(
                  top: 6.h,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withValues(alpha: 0.50),
                  textAlign: TextAlign.start,
                  text:
                  "I've been experiencing a nagging pain in my lower back, and I'm eager to get back to moving freely and feeling great.",
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                    height: 40.h,
                    radius: 16.r,
                    fontSize: 14.sp,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    bordersColor: AppColors.primary,
                    onPressed: () {}, label: 'Accept'),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CustomButton(
                    height: 40.h,
                    radius: 16.r,
                    fontSize: 14.sp,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.error,
                    bordersColor: AppColors.error,
                    onPressed: () {}, label: 'Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
