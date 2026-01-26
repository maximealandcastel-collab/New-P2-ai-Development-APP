import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/common/widgets/custom_textformfield.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/controller/trainer_and_user_set_up_porfile_controller.dart';

class AboutYouInputWidget extends StatelessWidget {
  const AboutYouInputWidget({super.key});

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
              text: "Write about yourself",
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: getHeight(24)),
          CustomTextFormField(
            controller: controller.aboutYouController,
            hintText: "Write something about yourself...",
            maxLines: 8,
          ),
        ],
      ),
    );
  }
}
