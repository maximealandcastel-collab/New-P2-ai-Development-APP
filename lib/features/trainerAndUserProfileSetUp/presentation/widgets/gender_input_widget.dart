import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/controller/trainer_and_user_set_up_porfile_controller.dart';

class GenderInputWidget extends StatelessWidget {
  const GenderInputWidget({super.key});

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
              text: "What’s your gender ?",
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: getHeight(24)),
          _helperGender(controller: controller, text: "Male"),
          SizedBox(height: getHeight(8)),
          _helperGender(controller: controller, text: "Female"),
          SizedBox(height: getHeight(8)),
          _helperGender(controller: controller, text: "Not prefer to say"),
        ],
      ),
    );
  }
}

Widget _helperGender({
  required String text,
  required TrainerAndUserSetUpPorfileController controller,
}) {
  return GestureDetector(
    onTap: () => controller.changeGender(text),
    child: Container(
      padding: EdgeInsets.all(getHeight(16)),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: text, fontSize: 16.sp, fontWeight: FontWeight.w600),
          Container(
            padding: EdgeInsets.all(getHeight(5)),
            decoration: BoxDecoration(
              color: AppColors.textFormFieldBorder.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            child: Obx(
              () => Container(
                padding: EdgeInsets.all(getHeight(6)),
                decoration: BoxDecoration(
                  color: controller.selectedGender.value == text
                      ? AppColors.textPrimary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
