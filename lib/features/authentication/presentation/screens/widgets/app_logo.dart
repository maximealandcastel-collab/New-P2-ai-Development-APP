import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({
    super.key,
    this.subtitle,
    this.title,
    this.size = 84,
    this.spacing,
    this.centerLogo = true,  this.topPadding = 0 ,
  });

  final String? title;
  final String? subtitle;
  final double size;
  final double topPadding;
  final double? spacing;
  final bool centerLogo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centerLogo
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        SizedBox(height: topPadding),
        Image.asset(
          Assets.images.logo.path,
          width: size.w,
          height: size.h,
        ),
       SizedBox(height: spacing ?? 16.h),
        if (title != null) ...[
          CustomText(
            textAlign: TextAlign.start,
            text: title ?? '',
            fontSize: 32.sp,
            fontWeight: FontWeight.w600,
          ),
        ]else
        RichText(
          text: TextSpan(
            text: 'Welcome to ',
            style: TextStyle(
              fontSize: 24.sp,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                style: TextStyle(color: AppColors.primary),
                text: 'P2P Fit Tech Ai',
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        if (subtitle != null)
          CustomText(text: subtitle ?? '', color: AppColors.textSecondary),
      ],
    );
  }
}
