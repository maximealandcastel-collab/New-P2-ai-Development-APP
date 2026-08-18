import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';

class CustomButton2 extends StatelessWidget {
  const CustomButton2({
    super.key,
    this.color,
    this.textStyle,
    this.paddingInner = EdgeInsets.zero,
    required this.onTap,
    required this.text,
    this.loading = false,
    this.width,
    this.height, this.borderRadius,
  });

  final Function() onTap;
  final String text;
  final bool loading;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? color;
  final EdgeInsetsGeometry paddingInner;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? () {} : onTap,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius??4.r)),
        backgroundColor: color ?? AppColors.secondary,
        minimumSize: Size(width ?? Get.width, height ?? 48.h),
          maximumSize: Size(width ?? Get.width, height ?? 48.h),
        padding: paddingInner,
        splashFactory: InkSplash.splashFactory,
          foregroundColor: AppColors.primary,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // its give 0 for all extra space Outside of button
        // visualDensity: VisualDensity.compact,  // its give 0 for all extra space inside button
      ),
      child: loading
          ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: const CircularProgressIndicator(color: Colors.white),
            )
          : Text(text,
        style: textStyle ??
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
      ),
    );
  }
}
