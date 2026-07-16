import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/data/models/gym_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class GymCardWidget extends StatelessWidget {
  const GymCardWidget({
    super.key,
    required this.gym,
    this.onJoinPressed,
  });

  final GymModel gym;
  final VoidCallback? onJoinPressed;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 12.r,
      bordersColor: AppColors.secondary,
      width: 110.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
            child: CustomNetworkImage(
              imageUrl: gym.imageUrl,
              height: 62.h,
              width: double.infinity,
            ),
          ),
          CustomText(
            top: 4.h,
            left: 4.w,
            right: 4.w,
            maxline: 1,
            textOverflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            text: gym.name,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 10.r),
                CustomText(
                  left: 4.w,
                  maxline: 1,
                  textOverflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  text: gym.distanceLabel,
                  fontSize: 10.sp,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: CustomButton(
              backgroundColor: AppColors.textSecondary.withValues(alpha: 0.7),
              onPressed: onJoinPressed,
              label: 'Disable',
              width: 50.w,
              height: 15.h,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }
}
