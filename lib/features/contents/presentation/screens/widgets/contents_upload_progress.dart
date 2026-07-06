import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsUploadProgress extends StatelessWidget {
  const ContentsUploadProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final contentController = ContentController.to;

    return Obx(() {
      if (!contentController.isSubmittingContent.value) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      final progress = contentController.submitProgress.value;
      final submitMessage = contentController.submitMessage.value;

      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: CustomContainer(
            color: Colors.white,
            paddingHorizontal: 16.w,
            paddingBottom: 12.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(99.r),
                  child: LinearProgressIndicator(
                    value: progress > 0 ? progress : null,
                    minHeight: 6.h,
                    backgroundColor: AppColors.backgroundLight,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 6.h),
                CustomText(
                  text: progress > 0
                      ? 'Uploading ${(progress * 100).round()}%'
                      : submitMessage,
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
