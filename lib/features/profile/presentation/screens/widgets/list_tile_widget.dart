import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContainerCard extends StatelessWidget {
  final String label;
  final String? sublabel;
  final List<Widget> children;

  const ContainerCard({
    super.key,
    required this.label,
    this.sublabel,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 20.r,
      paddingAll: 16.r,
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: label,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                bottom: 12.h,
              ),
              if (sublabel != null)
                CustomText(
                  text: sublabel!,
                  fontSize: 11.sp,
                  bottom: 12.h,
                  color: Colors.grey,
                ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}




class ListTileWidget extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final bool isSpacer;

  const ListTileWidget({
    super.key,
    required this.label,
    required this.onTap,
    this.textColor,
    this.isSpacer = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      marginBottom: isSpacer ? 8.h : 0,
      color: Colors.black.withValues(alpha: 0.05),
      width: double.infinity,
      paddingHorizontal: 16.w,
      paddingVertical: 14.h,
      radiusAll: 12.r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.black,
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}


