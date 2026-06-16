import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TapBarHelper extends StatelessWidget {
  const TapBarHelper({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final controller = SignUpController.to;
    return Obx(
          () => GestureDetector(
        onTap: () => controller.changeRole(text),
        child: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: controller.selectedRole == text
                ? AppColors.textPrimary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomText(
            color: controller.selectedRole == text ?
            AppColors.textWhite
                : AppColors.textSecondary,
            text: text,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
