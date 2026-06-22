import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/trainer/contents/data/models/category_model.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  void _openCreateCategory() {
    CategoryController.to.clearForm();
    Get.toNamed(AppRoute.createCategoryScreen)?.then((result) {
      if (result == true) CategoryController.to.fetchCategories();
    });
  }

  void _openEditCategory(CategoryModel category) {
    CategoryController.to.setEditCategory(category);
    Get.toNamed(
      AppRoute.createCategoryScreen,
      arguments: category,
    )?.then((result) {
      if (result == true) CategoryController.to.fetchCategories();
    });
  }

  void _showDeleteDialog(CategoryModel category) {
    showDialog<void>(
      context: Get.context!,
      builder: (ctx) => CustomDialog(
        title: 'Delete category?',
        subtitle: 'Are you sure you want to delete "${category.category}"?',
        confirmButtonText: 'Delete',
        onConfirm: () {
          Navigator.pop(ctx);
          if (category.id != null) {
            CategoryController.to.deleteCategory(category.id!);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.to;

    return SliverScaffold(
      appBarTitle: 'All category',
      onRefresh: controller.fetchCategories,
      slivers: (context) => [
        CustomText(
          left: 16.w,
          bottom: 12.h,
          textAlign: TextAlign.start,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          text: 'Categories',
        ).asSliver,
        Obx(() {
          switch (controller.loadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.h),
                  child: const Center(child: CustomLoader()),
                ),
              );
            case LoadingState.offline:
            case LoadingState.error:
              return EmptyDataWidget(
                message: 'Failed to load categories. Please try again.',
                onRefresh: controller.fetchCategories,
              ).asSliver;
            case LoadingState.loaded:
              if (controller.categories.isEmpty) {
                return const EmptyDataWidget(
                  message: 'No categories found.',
                ).asSliver;
              }

              return SliverList.separated(
                itemCount: controller.categories.length,
                itemBuilder: (_, index) {
                  final category = controller.categories[index];
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
                                text: category.category ?? '',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (category.isActive == false)
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
                                    _openEditCategory(category);
                                  } else if (value == 'Delete') {
                                    _showDeleteDialog(category);
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
                          text: category.description ?? '',
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
              ).asPaddedSliver(horizontal: 16.w);
          }
        }),
        SizedBox(height: 70.h).asSliver,
      ],
      floatingActionButton: IconButton(
        onPressed: _openCreateCategory,
        icon: Assets.icons.addButton.svg(height: 57.r, width: 57.r),
      ),
    );
  }
}
