import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/custom_assets/fonts.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
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
    this.loadingIndicatorColor,
    this.borderWidth,
    this.isDisabled = false,
  });

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
  final double? borderWidth;
  final bool elevation;
  final bool isLoading;
  final bool isDisabled;
  final Color? loadingIndicatorColor;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      elevation: elevation,
      onTap: isLoading ? null : onPressed,
      color: backgroundColor ?? (isDisabled ? Colors.black.withValues(alpha: 0.06) : AppColors.primary),
      height: height ?? 50.h,
      width: width ?? double.infinity,
      radiusAll: radius ?? 100.r,
      bordersColor: bordersColor,
      borderWidth: borderWidth ?? 0,
      child:
      child ??
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child:
            isLoading
                ? SizedBox(
              key: const ValueKey('loading'),
              height: 20.h,
              width: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  loadingIndicatorColor ??
                      foregroundColor ??
                      Colors.white,
                ),
              ),
            )
                : Row(
              key: const ValueKey('content'),
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Prefix Icon
                if (prefixIcon != null || prefixIconShow == true) ...[
                  prefixIcon!,
                  SizedBox(width: 8.w),
                ],

                if (title != null) title!,

                /// Label Text
                if (label != null)
                  Flexible(
                    child: CustomText(
                      text: label ?? '',
                      color: foregroundColor ?? (isDisabled ? Colors.black.withValues(alpha: 0.24) : Colors.white),
                      fontName:
                      fontName ?? FontFamily.figtree,
                      fontWeight: fontWeight ?? FontWeight.w600,
                      fontSize: fontSize ?? 20.sp,
                    ),
                  ),

                /// Suffix Icon
                if (suffixIcon != null || suffixIconShow == true) ...[
                  SizedBox(width: 8.w),
                  suffixIcon != null
                      ? suffixIcon!
                      : Icon(Icons.arrow_forward_ios),
                ],
              ],
            ),
          ),
    );
  }
}
