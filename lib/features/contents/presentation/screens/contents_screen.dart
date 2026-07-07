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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Obx(() => _buildContentBody(contentController)),
          ContentsReelsOverlay(
            onSearchTap: () => _openSearch(context, contentController),
          ),
          _buildBottomRefreshIndicator(context, contentController),
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

  Widget _buildContentBody(ContentController contentController) {
    switch (contentController.loadingState) {
      case LoadingState.initial:
      case LoadingState.loading:
        return const ColoredBox(
          color: AppColors.backgroundDark,
          child: Center(child: CustomLoader()),
        );
      case LoadingState.offline:
      case LoadingState.error:
        return ColoredBox(
          color: AppColors.backgroundDark,
          child: EmptyDataWidget(
            message: 'Content not found',
            onRefresh: contentController.refresh,
          ),
        );
      case LoadingState.loaded:
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
            _buildBottomPullUpDetector(contentController),
          ],
        );
    }
  }

  Widget _buildBottomPullUpDetector(ContentController contentController) {
    return Obx(() {
      if (contentController.currentReelIndex.value != 0) {
        return const SizedBox.shrink();
      }

      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        height: 180.h,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: contentController.onPullUpRefreshUpdate,
          onVerticalDragEnd: contentController.onPullUpRefreshEnd,
          onVerticalDragCancel: contentController.resetPullUpRefresh,
        ),
      );
    });
  }

  Widget _buildBottomRefreshIndicator(
    BuildContext context,
    ContentController contentController,
  ) {
    return Obx(() {
      final extent = contentController.pullUpRefreshExtent.value;
      final isRefreshing = contentController.isRefreshingFeed;
      if (!isRefreshing && extent <= 0) {
        return const SizedBox.shrink();
      }

      final bottomInset = MediaQuery.paddingOf(context).bottom;

      return Positioned(
        left: 0,
        right: 0,
        bottom: bottomInset + 88.h + extent,
        child: Center(
          child: CustomContainer(
            color: AppColors.backgroundLight.withValues(alpha: 0.92),
            radiusAll: 999.r,
            paddingHorizontal: 16.w,
            paddingVertical: 10.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomLoader(),
                SizedBox(width: 10.w),
                CustomText(
                  text: isRefreshing ? 'Refreshing...' : 'Pull up to refresh',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      );
    });
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
