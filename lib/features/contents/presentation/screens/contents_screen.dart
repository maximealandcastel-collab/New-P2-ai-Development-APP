import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_reel_item.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/contents_reels_overlay.dart';
import 'package:pler_to_pler_app/features/contents/reels/core/reel_colors.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/search_screen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:preload_page_view/preload_page_view.dart' hide PageScrollPhysics;

class ContentsScreen extends StatelessWidget {
  const ContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contentController = ContentController.to;

    return Scaffold(
      backgroundColor: ReelColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Obx(() {
            contentController.reelFeed!.loadingState.value;
            contentController.reelFeed!.feed.items.length;
            return _buildContentBody(context, contentController);
          }),
          ContentsReelsOverlay(
            onSearchTap: () => _openSearch(context, contentController),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody(
    BuildContext context,
    ContentController contentController,
  ) {
    switch (contentController.reelFeed!.loadingState.value) {
      case LoadingState.initial:
      case LoadingState.loading:
        return const ColoredBox(color: ReelColors.background);
      case LoadingState.offline:
      case LoadingState.error:
        return _buildEmptyState(contentController);
      case LoadingState.loaded:
        if (contentController.contents.isEmpty) {
          return _buildEmptyState(contentController);
        }

        final isFirstReel = contentController.currentReelIndex.value == 0;

        return RefreshIndicator(
          backgroundColor: ReelColors.background,
          color: AppColors.primary,
          edgeOffset: MediaQuery.paddingOf(context).top + 96.h,
          onRefresh: contentController.refresh,
          notificationPredicate: (notification) =>
              isFirstReel && notification.depth == 0,
          child: ColoredBox(
            color: ReelColors.background,
            child: _buildReelPageView(contentController),
          ),
        );
    }
  }

  Widget _buildReelPageView(ContentController contentController) {
    return PreloadPageView.builder(
      controller: contentController.pageController,
      scrollDirection: Axis.vertical,
      preloadPagesCount: 1,
      physics: const AlwaysScrollableScrollPhysics(
        parent: PageScrollPhysics(),
      ),
      itemCount: contentController.contents.length,
      onPageChanged: contentController.onReelPageChanged,
      itemBuilder: (context, index) {
        final content = contentController.contents[index];
        return ContentReelItem(
          key: ValueKey(content.id ?? 'content_$index'),
          content: content,
          index: index,
        );
      },
    );
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
                  image: ContentMediaResolver.resolveThumbnailUrl(content),
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
