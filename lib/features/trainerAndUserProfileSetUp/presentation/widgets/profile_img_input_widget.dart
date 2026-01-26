import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/core/utils/constants/image_path.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/controller/trainer_and_user_set_up_porfile_controller.dart';

class ProfileImgInputWidget extends StatelessWidget {
  const ProfileImgInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainerAndUserSetUpPorfileController>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() {
            if ((controller.selectedImage.value.isNotEmpty)) {
              return Stack(
                children: [
                  ClipOval(
                    child: Image.file(
                      File(controller.selectedImage.value),
                      height: getHeight(148),
                      width: getWidth(148),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        controller.selectedImage.value = "";
                      },
                      child: Container(
                        padding: EdgeInsets.all(getHeight(8)),
                        decoration: BoxDecoration(
                          color: AppColors.textWhite,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.delete,
                          size: 16.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return GestureDetector(
              onTap: () {
                controller.pickImage();
              },
              child: Image.asset(
                ImagePath.selectProfileImg,
                height: getHeight(148),
                width: getWidth(148),
                fit: BoxFit.cover,
              ),
            );
          }),
          SizedBox(height: getHeight(40)),
          CustomText(
            text: "Add a profile photo",
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(width: double.infinity),
        ],
      ),
    );
  }
}
