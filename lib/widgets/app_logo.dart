import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import '../../../custom_assets/assets.gen.dart';
import '../../../widgets/widgets.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({
    super.key,
    this.subtitle,
    this.size = 84,
    this.spacing, this.showLogo = true,
  });

  final String?  subtitle;
  final double size;
  final double? spacing;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if(showLogo)
        Assets.images.appLogo.image(height: size.h,width: size.w),
        SizedBox(height: spacing ?? 16.h),
        // if (title != null) ...[
        //   CustomText(
        //     textAlign: TextAlign.start,
        //     text: title ?? '',
        //     fontSize: 24.sp,
        //     fontWeight: FontWeight.w600,
        //   ),
          RichText(text: TextSpan(
            text: 'Welcome to ',
            style: TextStyle(fontSize: 24.sp, color: Colors.black,fontWeight: FontWeight.w600),
            children: [
              TextSpan(
                style: TextStyle(color: AppColors.primary),
                text: 'Pier to Pier',)]
          )),
          SizedBox(height: 10.h),
        //],

        if (subtitle != null)
          CustomText(
            text: subtitle ?? '',
           color: AppColors.textSecondary,

          ),
      ],
    );
  }
}
