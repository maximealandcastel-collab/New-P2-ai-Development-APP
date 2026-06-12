import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

class SubscribeOptionCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscribeOptionCard({super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
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
                  width: 32.w,
                  height: 32.w,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary :  Colors.white,
                      width: 2,
                  ),
                  child: Center(
                    child: CustomContainer(
                      width: 20.w,
                      height: 20.w,
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.primary : Color(0xffE6E6E6),
                    ),
                  )
                ),
              ],
            ),

            SizedBox(height: 10.h),
            CustomText(text:
              title,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 6.h),
            CustomText(text:
              description,
                fontSize: 10.sp,
                color: AppColors.textSecondary,
              textAlign: TextAlign.start,

            ),

          ],
        ),
      ),
    );
  }
}