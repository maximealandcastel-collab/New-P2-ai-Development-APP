import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

class SubscribeOptionCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? price;
  final String priceSuffix;
  final List<String> features;
  final bool isSelected;
  final bool showBadge;
  final String badgeTitle;
  final String badgeSubtitle;
  final VoidCallback onTap;

  const SubscribeOptionCard({
    super.key,
    required this.icon,
    required this.title,
    this.price,
    this.priceSuffix = '/month',
    required this.features,
    required this.isSelected,
    required this.onTap,
    this.showBadge = false,
    this.badgeTitle = '',
    this.badgeSubtitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.secondary,
          ),
          boxShadow: [
            if(!isSelected)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                icon,
                CustomContainer(
                  width: 26.w,
                  height: 26.w,
                  shape: BoxShape.circle,
                  bordersColor: isSelected
                      ? Colors.transparent
                  : AppColors.secondary,

                color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  child: isSelected
                      ? Icon(
                    Icons.check,
                    size: 18.sp,
                    color: Colors.white,
                  )
                      : null,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomText(
                  text: title,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.start,
                ),
                if (price != null) ...[
                  SizedBox(width: 6.w),
                  CustomText(
                    text: price!,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(width: 2.w),
                  CustomText(
                    text: priceSuffix,
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.start,
                  ),
                ],
              ],
            ),
            SizedBox(height: 8.h),
            ...features.map(
                  (f) => Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 14.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: CustomText(
                        text: f,
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showBadge) ...[
              SizedBox(height: 8.h),
              CustomContainer(
                width: double.infinity,
                paddingHorizontal: 12.w,
                paddingVertical: 8.h,
                radiusAll: 10.r,
                color: AppColors.primary.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: badgeTitle,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.start,
                        ),
                        CustomText(
                          text: badgeSubtitle,
                          fontSize: 9.sp,
                          color: AppColors.textSecondary,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}