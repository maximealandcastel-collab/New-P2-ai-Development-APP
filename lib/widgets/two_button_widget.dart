import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_sizer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TwoButtonWidget extends StatelessWidget {
  final List<Map<String, String>> buttons;
  final String selectedValue;
  final Function(String) onTap;
  final double? fontSize;
  final Color? selectedBgColor;
  final Color? bgColor;

  const TwoButtonWidget({
    super.key,
    required this.buttons,
    required this.selectedValue,
    required this.onTap,
    this.fontSize,
    this.selectedBgColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: buttons.map((item) {
        final isSelected = item['value'] == selectedValue;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(item['value']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              padding: EdgeInsets.symmetric(vertical: 9.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? (selectedBgColor ?? Colors.black)
                    : (bgColor ?? Colors.white),
                borderRadius: BorderRadius.circular(50.w),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: fontSize ?? 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(
                  item['label']!,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}