import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/controller/trainer_tax_info_and_paymnet_controller.dart';

class UploadTaxDocWidget extends StatelessWidget {
  const UploadTaxDocWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainerTaxInfoAndPaymnetController>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: CustomText(
              text: "Upload Tex document",
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.start,
            ),
          ),
          SizedBox(height: getHeight(40)),
          GestureDetector(
            onTap: () {
              controller.pickFile();
            },
            child: Obx(
              () => Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(getHeight(16)),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            top: getHeight(28),
                            bottom: getHeight(28),
                            right: getWidth(20),
                            left: getWidth(20),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.doc,
                            size: 24.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: getHeight(8)),
                        CustomText(
                          text: controller.filePath.value.isNotEmpty
                              ? controller.filePath.value.split("/").last
                              : "Only PDF accepted",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          textColor: controller.filePath.value.isNotEmpty
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  if (controller.filePath.value.isNotEmpty) ...[
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          controller.filePath.value = "";
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
