import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsCategoryChips extends StatelessWidget {
  const ContentsCategoryChips({super.key, this.forOverlay = false});

  final bool forOverlay;

  @override
  Widget build(BuildContext context) {
    final contentController = ContentController.to;
    final categoryController = CategoryController.to;

    return Obx(() {
      final categories = categoryController.categories;
      final selectedCategoryId = contentController.selectedCategoryId;

      return SizedBox(
        height: forOverlay ? 36.h : 40.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: forOverlay ? 12.w : 0),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final isSelected = isAll
                ? selectedCategoryId == null
                : selectedCategoryId == categories[index - 1].id;
            final label =
                isAll ? 'All' : categories[index - 1].category ?? '';

            return GestureDetector(
              onTap: () => contentController.selectCategory(
                isAll ? null : categories[index - 1].id,
              ),
              child: CustomContainer(
                bordersColor: forOverlay
                    ? (isSelected
                        ? AppColors.textWhite
                        : AppColors.textWhite.withValues(alpha: 0.55))
                    : (isSelected ? Colors.black : AppColors.secondary),
                radiusAll: 99.r,
                marginTop: forOverlay ? 0 : 3.h,
                marginLeft: forOverlay
                    ? (index == 0 ? 4.w : 0)
                    : (index == 0 ? 10.w : 0),
                marginBottom: forOverlay ? 0 : 3.h,
                marginRight: 8.w,
                paddingVertical: forOverlay ? 7.h : 6.h,
                paddingHorizontal: forOverlay ? 14.w : 12.r,
                color: forOverlay
                    ? (isSelected
                        ? AppColors.textWhite
                        : AppColors.backgroundDark.withValues(alpha: 0.35))
                    : (isSelected ? Colors.black : Colors.transparent),
                child: CustomText(
                  fontWeight: FontWeight.w600,
                  fontSize: forOverlay ? 13.sp : 16.sp,
                  color: forOverlay
                      ? (isSelected
                          ? AppColors.textPrimary
                          : AppColors.textWhite)
                      : (isSelected
                          ? Colors.white
                          : AppColors.textSecondary),
                  text: label,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
