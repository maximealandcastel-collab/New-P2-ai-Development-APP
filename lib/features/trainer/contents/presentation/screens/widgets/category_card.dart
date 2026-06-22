import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/contents/data/models/category_model.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({super.key, this.category});

  final CategoryModel? category;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.to;

    return CustomContainer(
      radiusAll: 12.r,
      paddingAll: 14.r,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  textAlign: TextAlign.start,
                  maxline: 1,
                  textOverflow: TextOverflow.ellipsis,
                  text: category?.category ?? '',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (category?.isActive == false)
                CustomContainer(
                  marginRight: 8.w,
                  paddingHorizontal: 8.w,
                  paddingVertical: 4.h,
                  radiusAll: 99.r,
                  color: AppColors.colorE6E6E6,
                  child: CustomText(
                    text: 'Inactive',
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              GestureDetector(
                onTapDown: (details) {
                  MenuShowHelper.showCustomMenu(
                    context: context,
                    details: details,
                    options: const ['Edit', 'Delete'],
                  ).then((value) {
                    if (value == 'Edit') {
                      CategoryController.to.setEditCategory(category);
                      Get.toNamed(
                        AppRoute.createCategoryScreen,
                        arguments: category,
                      );
                    } else if (value == 'Delete') {
                      showDialog(context: context, builder: (context) {
                        return Obx(() {
                          return CustomDialog(
                            title: 'Delete Category',
                            description:
                            'Are you sure you want to delete this category? This action cannot be undone.',
                            isLoading: controller.deleteLoadingState.isLoading,
                            rightButtonLabel: 'Yes, Delete',
                            onTapLeftButton: () {
                              Get.back(canPop: true);
                            },
                            onTapRightButton: () {
                              controller.deleteCategory(category?.id ?? '');
                            },
                          );
                        }
                        );
                      },);
                    }
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.more_vert_outlined,
                  size: 20.r,
                ),
              ),
            ],
          ),
          CustomText(
            textAlign: TextAlign.start,
            maxline: 2,
            textOverflow: TextOverflow.ellipsis,
            text: category?.description ?? '',
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
