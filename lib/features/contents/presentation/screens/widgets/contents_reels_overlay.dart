import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsReelsOverlay extends StatelessWidget {
  const ContentsReelsOverlay({
    super.key,
    required this.onSearchTap,
  });

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final contentController = ContentController.to;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, topPadding + 8.h, 0, 12.h),
        child: Column(
          children: [
            _buildTikTokHeader(contentController),
            Obx(() {
              if (!contentController.isSubmittingContent.value) {
                return const SizedBox.shrink();
              }

              final progress = contentController.submitProgress.value;
              final submitMessage = contentController.submitMessage.value;

              return Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                child: CustomContainer(
                  color: AppColors.backgroundLight,
                  radiusAll: 12.r,
                  paddingHorizontal: 12.w,
                  paddingVertical: 10.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99.r),
                        child: LinearProgressIndicator(
                          value: progress > 0 ? progress : null,
                          minHeight: 5.h,
                          backgroundColor: AppColors.secondary,
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
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTikTokHeader(ContentController contentController) {
    return Obx(() {
      final activeTab = contentController.activeTab.value;

      return SizedBox(
        height: 44.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab(
                  label: 'Default',
                  isActive: activeTab == ContentTab.defaultContent,
                  onTap: () =>
                      contentController.changeTab(ContentTab.defaultContent),
                ),
                SizedBox(width: 24.w),
                _buildTab(
                  label: 'My Trainer',
                  isActive: activeTab == ContentTab.myTrainer,
                  onTap: () =>
                      contentController.changeTab(ContentTab.myTrainer),
                ),
              ],
            ),
            Positioned(
              right: 16.w,
              child: GestureDetector(
                onTap: onSearchTap,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.search_rounded,
                  color: AppColors.textWhite,
                  size: 24.r,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: label,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            fontSize: 15.sp,
            color: AppColors.textWhite
          ),
          SizedBox(height: 4.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 2.h,
            width: isActive ? 24.w : 0,
            decoration: BoxDecoration(
              color: isActive ? AppColors.textWhite : Colors.transparent,
              borderRadius: BorderRadius.circular(99.r),
            ),
          ),
        ],
      ),
    );
  }
}
