import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import '../widgets/widgets.dart';


class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      this.suffixIcon,
      this.child,
      this.label,
      this.backgroundColor,
      this.foregroundColor,
      this.height,
      this.width,
      this.fontWeight,
      this.fontSize,
      this.fontName,
      required this.onPressed,
      this.radius,
      this.prefixIcon,
      this.bordersColor,
      this.suffixIconShow = false,
      this.prefixIconShow = false,
      this.title,
      this.iconHeight,
      this.iconWidth,
      this.elevation = false,
      this.isLoading = false,
      this.isDisabled = false});

  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Widget? child;
  final String? label;
  final Widget? title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? radius;
  final String? fontName;
  final VoidCallback? onPressed;
  final Color? bordersColor;
  final bool suffixIconShow;
  final bool prefixIconShow;
  final double? iconHeight;
  final double? iconWidth;
  final bool elevation;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      elevation: elevation,
      onTap: (isLoading || isDisabled) ? null : onPressed,
      color: (backgroundColor ?? AppColors.primary).withOpacity((isLoading || isDisabled) ? 0.4 : 1.0),
      height: height ?? 48.h,
      width: width ?? double.infinity,
      radiusAll: radius ?? 16.r,
      bordersColor: bordersColor,
      child: child ?? Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              height: 20.h,
              width: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                valueColor: AlwaysStoppedAnimation<Color>(
                  foregroundColor ?? Colors.white,
                ),
              ),
            )
          else ...[
            /// Prefix Icon
            if (prefixIcon != null || prefixIconShow == true) ...[prefixIcon!,
              SizedBox(width: 8.w),
            ], ?title,

            /// Label Text
            if (label != null)
              Flexible(
                child: CustomText(
                  text: label ?? '',
                  color: foregroundColor ?? Colors.white,
                  fontName: fontName, // null = SF Pro on iOS
                  fontWeight: fontWeight ?? FontWeight.w600,
                  fontSize: fontSize ?? 16.sp,
                ),
              ),

            /// Suffix Icon
            if (suffixIcon != null || suffixIconShow == true) ...[
              SizedBox(width: 8.w),
              suffixIcon != null
                  ? suffixIcon!
                  : const Icon(Icons.arrow_forward_ios),
            ],
          ],
        ],
      ),
    );
  }
}
