import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
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
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Obx(() => _buildContentBody(context, contentController)),
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
      ),
    );
  }

  Widget _buildContentBody(
    BuildContext context,
    ContentController contentController,
  ) {
    switch (contentController.loadingState) {
      case LoadingState.initial:
      case LoadingState.loading:
        return const ColoredBox(
          color: AppColors.backgroundDark,
          child: Center(child: CustomLoader()),
        );
      case LoadingState.offline:
      case LoadingState.error:
        return _buildEmptyState(contentController);
      case LoadingState.loaded:
        if (contentController.contents.isEmpty) {
          return _buildEmptyState(contentController);
        }

        final isFirstReel = contentController.currentReelIndex.value == 0;

        return RefreshIndicator(
          backgroundColor: AppColors.backgroundLight,
          color: AppColors.primary,
          edgeOffset: MediaQuery.paddingOf(context).top + 96.h,
          onRefresh: contentController.refresh,
          notificationPredicate: (notification) =>
              isFirstReel && notification.depth == 0,
          child: ColoredBox(
            color: AppColors.backgroundDark,
            child: PageView.builder(
              controller: contentController.pageController,
              scrollDirection: Axis.vertical,
              allowImplicitScrolling: true,
              physics: const AlwaysScrollableScrollPhysics(
                parent: PageScrollPhysics(),
              ),
              itemCount: contentController.contents.length,
              onPageChanged: contentController.onReelPageChanged,
              itemBuilder: (context, index) {
                final content = contentController.contents[index];
                return ContentReelItem(content: content, index: index);
              },
            ),
          ),
        );
    }
  }

  Widget _buildEmptyState(ContentController contentController) {
    return EmptyDataWidget(
      message: 'No content available',
      messageColor: AppColors.textWhite,
      onRefresh: contentController.refresh,
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
          final content = result.model as ContentModel;
          controller.search.clear();
          controller.pauseReel();
          Get.back();
          Get.toNamed(AppRoute.contentDetailsScreen, arguments: content);
        },
      ),
    );
  }
}
