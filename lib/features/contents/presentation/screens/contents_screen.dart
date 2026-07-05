import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_card.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_shimmer.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
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
      edgeOffset: MediaQuery.heightOf(context) * 0.25,
      child: CustomScrollView(
        controller: contentController.scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          FeedAppBarSliver(
            pinned: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(
                ProfileController.to.userData?.role == 'trainer' ? 110.h : 160.h,
              ),
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
                      
                      // Default and My Trainer selection tabs
                      Obx(() {
                        final isTrainer = ProfileController.to.userData?.role == 'trainer';
                        if (isTrainer) return const SizedBox.shrink();

                        final isDefault = contentController.activeTab.value == ContentTab.defaultContent;
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => contentController.changeTab(ContentTab.defaultContent),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 8.h),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: isDefault ? AppColors.primary : Colors.transparent,
                                              width: 2.w,
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: CustomText(
                                            text: 'Default',
                                            fontWeight: isDefault ? FontWeight.w600 : FontWeight.w400,
                                            color: isDefault ? AppColors.primary : AppColors.textSecondary,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => contentController.changeTab(ContentTab.myTrainer),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 8.h),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: !isDefault ? AppColors.primary : Colors.transparent,
                                              width: 2.w,
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: CustomText(
                                            text: 'My Trainer',
                                            fontWeight: !isDefault ? FontWeight.w600 : FontWeight.w400,
                                            color: !isDefault ? AppColors.primary : AppColors.textSecondary,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.h),
                          ],
                        );
                      }),

                      // Conditional Search Field or Category Chips
                      Obx(() {
                        final isTrainer = ProfileController.to.userData?.role == 'trainer';
                        if (!isTrainer && contentController.activeTab.value == ContentTab.defaultContent) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: CustomSearchField(
                              searchController: contentController.searchController,
                              hintText: 'Search default exercises...',
                              onChanged: (val) {
                                contentController.searchQuery.value = val;
                              },
                            ),
                          );
                        } else {
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
                                    : selectedCategoryId ==
                                        categories[index - 1].id;
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
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.transparent,
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
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
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
          }),
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
                final isTrainer = ProfileController.to.userData?.role == 'trainer';
                final showActions = isTrainer && (contentController.activeTab.value != ContentTab.defaultContent);

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
                          showActions: showActions,
                        ),
                      );
                    },
                  ),
                );
            }
          }),
          PaginationLoaderSliver(controller: contentController),
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      ),
    );
  }
}
