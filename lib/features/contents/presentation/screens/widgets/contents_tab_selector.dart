import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsTabSelector extends StatelessWidget {
  const ContentsTabSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final contentController = ContentController.to;

    return Obx(() {
      final isDefault =
          contentController.activeTab.value == ContentTab.defaultContent;

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabItem(
                    label: 'Default',
                    isSelected: isDefault,
                    onTap: () =>
                        contentController.changeTab(ContentTab.defaultContent),
                  ),
                ),
                Expanded(
                  child: _buildTabItem(
                    label: 'My Trainer',
                    isSelected: !isDefault,
                    onTap: () =>
                        contentController.changeTab(ContentTab.myTrainer),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
        ],
      );
    });
  }

  Widget _buildTabItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2.w,
            ),
          ),
        ),
        child: Center(
          child: CustomText(
            text: label,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }
}
