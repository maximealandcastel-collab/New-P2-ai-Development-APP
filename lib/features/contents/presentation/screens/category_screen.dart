import 'package:pler_to_pler_app/core/themes/brand_color_mapper.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/category_card.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/category_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.to;

    return SliverScaffold(
      appBar: CustomSliverAppBar(
        title: 'All category',
      ),
      onRefresh: controller.fetchCategories,
      bodyList: [
        CustomText(
          left: 16.w,
          bottom: 12.h,
          textAlign: TextAlign.start,
          fontSize: 16.sp,
          fontWeight: AppFontWeight.label,
          text: 'Categories',
        ).asSliver,
        Obx(() {
          switch (controller.loadingState) {
            case LoadingState.initial:
            case LoadingState.loading:
              return const CategoryShimmer().asSliver;
            case LoadingState.offline:
            case LoadingState.error:
              return EmptyDataWidget(
                message: 'Category not found',
                onRefresh: controller.fetchCategories,
              ).asSliver;
            case LoadingState.loaded:
              if (controller.categories.isEmpty) {
                return EmptyDataWidget(
                  message: 'Category not found',
                  onRefresh: controller.fetchCategories,
                ).asSliver;
              }
              return SliverList.separated(
                itemCount: controller.categories.length,
                itemBuilder: (_, index) {
                  final category = controller.categories[index];
                  return ContentCard(category: category);
                },
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
              ).asPaddedSliver(horizontal: 16.w);
          }
        }),
        SizedBox(height: 70.h).asSliver,
      ],
      floatingActionButton: IconButton(
        onPressed: () {
          CategoryController.to.clearForm();
          Get.toNamed(AppRoute.createCategoryScreen);
        },
        icon: Assets.icons.addButton.svg(
      colorMapper: BrandColorMapper(Theme.of(context).colorScheme.primary), height: 57.r, width: 57.r),
      ),
    );
  }
}
