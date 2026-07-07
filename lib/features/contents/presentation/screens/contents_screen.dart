import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_reel_item.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/contents_reels_overlay.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/search_screen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsScreen extends StatelessWidget {
  const ContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contentController = ContentController.to;

    return Scaffold(
      body: Obx(() {
        switch (contentController.loadingState) {
          case LoadingState.initial:
          case LoadingState.loading:
            return const ColoredBox(
              color: AppColors.backgroundLight,
              child: CustomLoader(),
            );
          case LoadingState.offline:
          case LoadingState.error:
            return EmptyDataWidget(
              message: 'Content not found',
              onRefresh: contentController.refresh,
            );
          case LoadingState.loaded:
            if (contentController.contents.isEmpty) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: AppColors.backgroundLight),
                  ContentsReelsOverlay(
                    onSearchTap: () => _openSearch(context, contentController),
                  ),
                  Center(
                    child: EmptyDataWidget(
                      message: contentController.activeTab.value ==
                              ContentTab.myTrainer
                          ? 'No content found in this category'
                          : 'Content not found',
                      onRefresh: contentController.refresh,
                    ),
                  ),
                ],
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: contentController.pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: contentController.contents.length,
                  onPageChanged: contentController.onReelPageChanged,
                  itemBuilder: (context, index) {
                    final content = contentController.contents[index];
                    return ContentReelItem(content: content, index: index);
                  },
                ),
                ContentsReelsOverlay(
                  onSearchTap: () => _openSearch(context, contentController),
                ),
                Obx(() {
                  if (!contentController.showPaginationLoader) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 110.h,
                    child: Center(
                      child: CustomContainer(
                        color: AppColors.backgroundLight.withValues(
                          alpha: 0.92,
                        ),
                        radiusAll: 999.r,
                        paddingHorizontal: 14.w,
                        paddingVertical: 8.h,
                        child: const CustomLoader(),
                      ),
                    ),
                  );
                }),
              ],
            );
        }
      }),
    );
  }

  void _openSearch(BuildContext context, ContentController controller) {
    showSearch(
      context: context,
      delegate: SearchScreen(
        hintText: 'Search default exercises...',
        onSearch: (String query) async {
          await controller.search.search(query);
          return controller.search.results
              .map(
                (content) => SearchModel(
                  model: content,
                  title: content.title ?? content.exerciseName,
                  image: content.thumbnailUrl,
                  subtitle: content.categoryId?.category ?? content.difficulty,
                ),
              )
              .toList();
        },
        onResultTap: (result) {
          controller.search.clear();
          controller.openContentInFeed(result.model as ContentModel);
        },
      ),
    );
  }
}
