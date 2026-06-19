import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/dialog_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class FindTrainerCard extends StatelessWidget {
  final FindTrainerModel? trainer;

  const FindTrainerCard({super.key, this.trainer});

  @override
  Widget build(BuildContext context) {
    final controller = SubscribeController.to;
    return CustomContainer(
      color: Colors.white,
      radiusAll: 16.r,
      paddingAll: 16.r,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomNetworkImage(
                boxShape: BoxShape.circle,
                height: 48.r,
                width: 48.r,
                imageUrl: '',
              ),

              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      textAlign: TextAlign.start,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      maxline: 1,
                      textOverflow: TextOverflow.ellipsis,
                      text: trainer?.name ?? '',
                    ),
                    CustomText(
                      textAlign: TextAlign.start,
                      top: 6.h,
                      maxline: 1,
                      textOverflow: TextOverflow.ellipsis,
                      color: AppColors.textSecondary,
                      text: StringFormat.formatSpecialty(trainer?.specialty ?? '') ,
                    ),
                  ],
                ),
              ),

              CustomText(
                textAlign: TextAlign.start,
                fontSize: 12.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                text: 'monthly \$${trainer?.subscriptionPrice?.premium ?? '0'}',
              ),
            ],
          ),

          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  radius: 12.r,
                  bordersColor: Colors.black.withValues(alpha: 0.16),
                  backgroundColor: Colors.black.withValues(alpha: 0.04),
                  foregroundColor: AppColors.textPrimary,
                  fontSize: 14.sp,
                  height: 32.h,
                  onPressed: () {
                    Get.toNamed(AppRoute.trainerProfileScreen);
                  },
                  label: 'View profile',
                ),
              ),

              SizedBox(width: 16.w),

              Expanded(
                child: CustomButton(
                  radius: 12.r,
                  bordersColor: Colors.black.withValues(alpha: 0.16),
                  backgroundColor: Colors.white.withValues(alpha: 0.04),
                  foregroundColor: AppColors.textPrimary,
                  fontSize: 14.sp,
                  height: 32.h,
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      context: context,
                      builder: (context) {
                        return Obx(() => DialogShowHelper.showBottomSheet(
                          context,
                          title: 'Trainer request',
                          content: CustomTextField(
                            controller: controller.noteTEController,
                            contentPaddingVertical: 10.h,
                            labelText: 'Note :',
                            hintText: 'Write a short message ',
                            maxLines: 5,
                            minLines: 5,
                          ),
                          buttonLabel: 'Request trainer',
                          isLoading: controller.requestLoadingState.isLoading,
                          onTapConfirm: () => controller.requestTrainer(trainer?.sId ?? ''),
                        ));
                      },
                    );
                  },
                  label: 'Request',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
