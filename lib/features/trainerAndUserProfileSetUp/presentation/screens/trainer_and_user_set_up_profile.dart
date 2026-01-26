import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_submit_button.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/core/utils/constants/image_path.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/controller/trainer_and_user_set_up_porfile_controller.dart';

class TrainerAndUserSetUpProfile extends StatelessWidget {
  TrainerAndUserSetUpProfile({super.key});

  final controller = Get.find<TrainerAndUserSetUpPorfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(getHeight(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => controller.tapBack(),
                    child: Container(
                      padding: EdgeInsets.all(getHeight(10)),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_ios, size: 18.sp),
                    ),
                  ),
                  SizedBox(width: getWidth(10)),
                  Obx(
                    () => Expanded(
                      child: Row(
                        children: controller.pageList.asMap().entries.map((
                          entry,
                        ) {
                          int index = entry.key;

                          return Expanded(
                            child: Container(
                              height: getHeight(6),
                              margin: EdgeInsets.symmetric(
                                horizontal: getWidth(4),
                              ),
                              decoration: BoxDecoration(
                                color: index <= controller.currentIndex.value
                                    ? AppColors
                                          .textPrimary // active/complete
                                    : AppColors.textGrey, // inactive
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  SizedBox(width: getWidth(10)),
                  GestureDetector(
                    onTap: () {
                      log("Skip all");
                    },
                    child: CustomText(
                      text: "Skip",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: getHeight(36)),
              Image.asset(
                ImagePath.appLogo,
                width: getWidth(84),
                height: getHeight(84),
                fit: BoxFit.cover,
              ),
              SizedBox(height: getHeight(16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: "Welcome to ",
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomText(
                    text: "Pier to Pier",
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.primary,
                  ),
                ],
              ),
              SizedBox(height: getHeight(8)),
              CustomText(
                text: "Let’s start with building your profile",
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                textColor: AppColors.textSecondary,
              ),
              SizedBox(height: getHeight(40)),
              Obx(
                () => Expanded(
                  child: SingleChildScrollView(
                    child: IndexedStack(
                      index: controller.currentIndex.value,
                      children: controller.pageList,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.currentIndex.value == 3) ...[
                  CustomSubmitButton(
                    text: "Maybe later",
                    onTap: () {
                      controller.tapNext();
                    },
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    textColor: AppColors.textPrimary,
                  ),
                  SizedBox(height: getHeight(20)),
                ],
                CustomSubmitButton(
                  text: "Next",
                  onTap: () {
                    controller.tapNext();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
