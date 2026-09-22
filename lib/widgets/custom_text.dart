import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';


class CustomText extends StatelessWidget {
  const CustomText(
      {super.key,
      this.maxline,
      this.textOverflow,
      this.fontName,
      this.textAlign = TextAlign.center,
      this.left = 0,
      this.right = 0,
      this.top = 0,
      this.bottom = 0,
      this.fontSize,
      this.textHeight,
      this.fontWeight = AppFontWeight.body,
      this.color,
      required this.text,
      this.onTap, this.decorationColor, this.decoration});

  final double left;
  final TextOverflow? textOverflow;
  final double right;
  final double top;
  final double bottom;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final Color? decorationColor;
  final String text;
  final TextAlign textAlign;
  final int? maxline;
  final String? fontName;
  final double? textHeight;
  final VoidCallback? onTap;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding:
            EdgeInsets.only(left: left, right: right, top: top, bottom: bottom),
        child: Text(
          textAlign: textAlign,
          text,
          maxLines: maxline,
          overflow: textOverflow,
          style: TextStyle(
            decoration: decoration,
            decorationColor: decorationColor,
            fontSize: fontSize ?? 13.sp,
            height: textHeight,
            fontFamily: fontName, // null → SF Pro on iOS, Roboto on Android
            fontWeight: fontWeight,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
