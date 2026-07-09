import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class EmptyData extends StatelessWidget {
  const EmptyData({
    super.key,
    required this.title,
    required this.subtitle,
    this.isRecommendation = true,
  });

  final String title;
  final String subtitle;
  final bool isRecommendation;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: Colors.white,
      radiusAll: 16.r,
      paddingAll: 14.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textAlign: TextAlign.start,
            text: title,
            fontWeight: FontWeight.w600,
            fontSize: 16.h,
          ),
          SizedBox(height: 16.h),
          Center(child: Assets.icons.empty.svg()),
          Center(
            child: CustomText(
              textAlign: TextAlign.start,
              top: 10.h,
              text: subtitle,
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          if(isRecommendation)...[
            SizedBox(height: 10.h),
            CustomContainer(
              width: double.infinity,
              paddingVertical: 8.h,
              paddingHorizontal: 14.w,
              radiusAll: 16.r,
              color: Colors.black.withValues(alpha: 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    textAlign: TextAlign.start,
                    fontSize: 12.sp,
                    color: Colors.black.withValues(alpha: 0.5),
                    text: 'Recommendation',
                  ),
                  CustomText(
                    textAlign: TextAlign.start,
                    fontSize: 12.sp,
                    text: 'Set your workout goal to get data',
                  ),
                ],
              ),
            ),
          ],

        ],
      ),
    );
  }
}
