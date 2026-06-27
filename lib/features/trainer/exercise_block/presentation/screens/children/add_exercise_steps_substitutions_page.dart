import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/create_exercise_block_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AddExerciseStepsSubstitutionsPage extends StatelessWidget {
  const AddExerciseStepsSubstitutionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CreateExerciseBlockController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CompleteProfilePageTitle(text: 'Steps & substitutions'),
        SizedBox(height: 16.h),
        CustomText(
          text: 'Substitutions',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 12.h),
        Obx(() {
          if (controller.hasSubstitutions) {
            return CustomContainer(
              width: double.infinity,
              marginBottom: 8.h,
              paddingHorizontal: 12.w,
              paddingVertical: 12.h,
              radiusAll: 12.r,
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Substitutions',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.start,
                        ),
                        ...controller.draftSubstitutions.entries.map((entry) {
                          final label =
                              CreateExerciseBlockController.substitutionLabels[
                                      entry.key] ??
                                  entry.key;
                          return CustomText(
                            top: 6.h,
                            text: '$label: ${entry.value}',
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.start,
                          );
                        }),
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: controller.removeSubstitutions,
                    child: Icon(
                      Icons.delete_outline,
                      size: 22.sp,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomButton(
            onPressed: controller.onOpenSubstitutions,
            label: 'Add substitutions',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            bordersColor: AppColors.primary,
            radius: 16.r,
            prefixIcon: Icon(
              Icons.add_rounded,
              size: 20.sp,
              color: AppColors.primary,
            ),
            prefixIconShow: true,
          );
        }),
        SizedBox(height: 20.h),
        CustomText(
          text: 'Created steps',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 12.h),
        CustomButton(
          onPressed: controller.onOpenExerciseSteps,
          label: 'Add steps',
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          bordersColor: AppColors.primary,
          radius: 16.r,
          prefixIcon: Icon(
            Icons.add_rounded,
            size: 20.sp,
            color: AppColors.primary,
          ),
          prefixIconShow: true,
        ),
        SizedBox(height: 12.h),
        Obx(() {
          if (controller.draftSteps.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            children: List.generate(controller.draftSteps.length, (index) {
              final step = controller.draftSteps[index];
              return CustomContainer(
                width: double.infinity,
                marginBottom: 8.h,
                paddingHorizontal: 12.w,
                paddingVertical: 12.h,
                radiusAll: 12.r,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        text: step.instruction,
                        fontSize: 16.sp,
                        maxline: 1,
                        textOverflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => controller.removeDraftStep(index),
                      child: Icon(
                        Icons.delete_outline,
                        size: 22.sp,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}
