import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/custom_assets/fonts.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AiInsightWidget extends StatelessWidget {
  const AiInsightWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return             CustomContainer(
      linearColors: [Color(0xff25AB4B).withOpacity(0.4), Colors.white.withOpacity(0.4), Colors.white,Colors.white],
      radiusAll: 16.r,
      paddingAll: 16.r,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: FontFamily.figtree,
              ),
              children: [
                WidgetSpan(child: Assets.icons.ai.svg()),
                TextSpan(text: ' AI Insight'),
              ],
            ),
          ),

          CustomText(
            text: '⚠️ Sarah reported increased knee pain today',
            fontWeight: FontWeight.w500,
            top: 12.h,
          ),

          CustomContainer(
            marginTop: 12.h,
            radiusAll: 12.r,
            paddingAll: 12.r,
            width: double.infinity,
            color: Colors.black.withOpacity(0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Recommendation',
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
                CustomText(
                  textAlign: TextAlign.start,
                  text:
                  'adjusting her strategy while indulging in a relaxing massage to alleviate discomfort and promote overall well-being.',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),

          CustomContainer(
            marginTop: 8.h,
            radiusAll: 50.r,
            paddingAll: 6.r,
            width: double.infinity,
            color: Colors.black.withOpacity(0.08),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    left: 6.w,
                    textAlign: TextAlign.start,
                    text: 'Was this insight was helpful ?',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                CustomContainer(
                  onTap: (){},
                  paddingAll: 5.r,
                  shape: BoxShape.circle,
                  bordersColor: AppColors.textSecondary,
                  child: Icon(Icons.thumb_up_alt,size: 16.r,color: AppColors.textPrimary,),
                ),

                CustomContainer(
                  marginLeft: 4.w,
                  onTap: (){},
                  paddingAll: 5.r,
                  shape: BoxShape.circle,
                  bordersColor: AppColors.textSecondary,
                  child: Icon(Icons.thumb_down_alt,size: 16.r,color: AppColors.textPrimary,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
