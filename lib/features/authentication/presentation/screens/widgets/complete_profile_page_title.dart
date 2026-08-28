import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CompleteProfilePageTitle extends StatelessWidget {
  const CompleteProfilePageTitle({
    super.key,
    required this.text,
    this.center = false,
  });

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final title = CustomText(
      text: text,
      fontSize: 24.sp,
      fontWeight: AppFontWeight.label,
      textAlign: center ? TextAlign.center : TextAlign.start,
    );

    return center ? Center(child: title) : title;
  }
}
