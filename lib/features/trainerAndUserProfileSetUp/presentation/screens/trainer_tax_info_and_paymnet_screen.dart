import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_submit_button.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/controller/trainer_tax_info_and_paymnet_controller.dart';

class TrainerTaxInfoAndPaymnetScreen extends StatelessWidget {
  TrainerTaxInfoAndPaymnetScreen({super.key});

  final controller = Get.find<TrainerTaxInfoAndPaymnetController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(getHeight(20)),
          child: Column(
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
                      // Get.offAll(() => TrainerTaxInfoAndPaymnetScreen());
                    },
                    child: CustomText(
                      text: "Skip",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
          padding: EdgeInsets.all(getHeight(20)),
          child: CustomSubmitButton(
            text: "Next",
            onTap: () {
              controller.tapNext();
            },
          ),
        ),
      ),
    );
  }
}
