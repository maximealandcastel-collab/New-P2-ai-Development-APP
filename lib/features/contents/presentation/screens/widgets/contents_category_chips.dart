import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsCategoryChips extends StatelessWidget {
  const ContentsCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final contentController = ContentController.to;
    final categoryController = CategoryController.to;

    return Obx(() {
      final categories = categoryController.categories;
      final selectedCategoryId = contentController.selectedCategoryId;

      return SizedBox(
        height: 40.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
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
                bordersColor:
                    isSelected ? Colors.black : AppColors.secondary,
                radiusAll: 99.r,
                marginTop: 3.h,
                marginLeft: index == 0 ? 10.w : 0,
                marginBottom: 3.h,
                marginRight: 6.w,
                paddingVertical: 6.h,
                paddingHorizontal: 12.r,
                color: isSelected ? Colors.black : Colors.transparent,
                child: CustomText(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color:
                      isSelected ? Colors.white : AppColors.textSecondary,
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
