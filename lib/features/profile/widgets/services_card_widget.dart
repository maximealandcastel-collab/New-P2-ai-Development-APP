import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/custom_assets/fonts.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ServicesCardWidget extends StatelessWidget {
  const ServicesCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginTop: 8.h,
      radiusAll: 12.r,
      color: Colors.white,
      paddingAll: 16.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textAlign: TextAlign.start,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            bottom: 6.h,
            text: '1-on-1 In-Person Training',
          ),
          CustomText(
            textAlign: TextAlign.start,
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            bottom: 6.h,
            text: 'The "classic" model. The trainer is with you for the full hour, correcting form, spotting weights, and motivating you.',
          ),Row(
            children: [
              Expanded(
                child: CustomText(
                  textAlign: TextAlign.start,
                  fontWeight: FontWeight.w600,
                  text: 'John Adams',
                ),
              ),

              RichText(text: TextSpan(
                style: TextStyle(
                    fontFamily: FontFamily.figtree,
                    color: AppColors.info,
                  fontWeight:FontWeight.w700,
                  fontSize: 14.sp
                ),
                text: '\$24 – \$48',
                children: [TextSpan(
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight:FontWeight.w400,
                    ),
                  text: ' / hour'
                )],
              ))
            ],
          ),
        ],
      ),
    );
  }
}
