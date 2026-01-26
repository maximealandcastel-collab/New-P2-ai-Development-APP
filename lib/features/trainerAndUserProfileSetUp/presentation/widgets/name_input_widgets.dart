import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/common/widgets/custom_textformfield.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/controller/trainer_and_user_set_up_porfile_controller.dart';

class NameInputWidgets extends StatelessWidget {
  const NameInputWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainerAndUserSetUpPorfileController>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: CustomText(
              text: "What’s your name ?",
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: getHeight(24)),
          CustomText(
            text: "First name",
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            textColor: AppColors.textSecondary,
          ),
          SizedBox(height: getHeight(4)),
          CustomTextFormField(
            controller: controller.firstNameController,
            hintText: "Enter your first name",
            prefixIcon: Icon(Icons.person, size: 24.sp),
          ),
          SizedBox(height: getHeight(24)),
          CustomText(
            text: "Last name",
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            textColor: AppColors.textSecondary,
          ),
          SizedBox(height: getHeight(4)),
          CustomTextFormField(
            controller: controller.lastNameController,
            hintText: "Enter your last name",
            prefixIcon: Icon(Icons.person, size: 24.sp),
          ),
        ],
      ),
    );
  }
}
