import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/widgets/content_card.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/widgets/content_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsScreen extends StatelessWidget {
  const ContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contentController = ContentController.to;
    final categoryController = CategoryController.to;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundLight,
      onRefresh: contentController.refresh,
      edgeOffset: 190.h,
      child: CustomScrollView(
        controller: contentController.scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          FeedAppBarSliver(
            pinned: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(98.h),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                child: CustomContainer(
                  topLeftRadius: 16.r,
                  topRightRadius: 16.r,
                  paddingTop: 16.h,
                  paddingBottom: 8.h,
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        left: 16.w,
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        text: 'All Contents',
                      ),
                      SizedBox(height: 8.h),
                      Obx(() {
                        final categories = categoryController.categories;
                        final selectedCategoryId =
                            contentController.selectedCategoryId;

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
                              final label = isAll
                                  ? 'All'
                                  : categories[index - 1].category ?? '';

                              return GestureDetector(
                                onTap: () => contentController.selectCategory(
                                  isAll ? null : categories[index - 1].id,
                                ),
                                child: CustomContainer(
                                  bordersColor: isSelected
                                      ? Colors.black
                                      : AppColors.secondary,
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
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    text: label,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            switch (contentController.loadingState) {
              case LoadingState.initial:
              case LoadingState.loading:
                return const ContentShimmer().asSliver;
              case LoadingState.offline:
              case LoadingState.error:
                return CustomContainer(
                  horizontalMargin: 16.h,
                  bottomLeft: 16.r,
                  bottomRight: 16.r,
                  paddingBottom: 16.h,
                  color: Colors.white,
                  child: EmptyDataWidget(
                    message: 'Content not found ',
                    onRefresh: contentController.refresh,
                  ),
                ).asSliver;
              case LoadingState.loaded:
                // if (contentController.contents.isEmpty) {
                //   return const EmptyDataWidget(
                //     message: 'No contents found.',
                //   ).asSliver;
                // }

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  sliver: SliverList.builder(
                    itemCount: contentController.contents.length,
                    itemBuilder: (context, index) {
                      final content = contentController.contents[index];
                      return CustomContainer(
                        color: Colors.white,
                        paddingTop: 8.h,
                        paddingLeft: 16.w,
                        paddingRight: 16.w,
                        child: ContentCard(
                          content: content,
                        ),
                      );
                    },
                  ),
                );
            }
          }),
          Obx(() {
            final showLoader = contentController.loadingState ==
                    LoadingState.loaded &&
                contentController.contentList.isLoadingMore.value;

            if (!showLoader) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const CustomLoader(),
              ),
            );
          }),
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      ),
    );
  }
}
