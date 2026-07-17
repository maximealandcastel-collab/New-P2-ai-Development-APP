import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/contents_reel_page_view.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/contents_reels_overlay.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/search_screen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsScreen extends StatelessWidget {
  const ContentsScreen({super.key});

  static const _background = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    final controller = ContentController.to;

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Obx(() {
            controller.reelFeed!.loadingState.value;
            return _buildBody(context, controller);
          }),
          ContentsReelsOverlay(
            onSearchTap: () => _openSearch(context, controller),
          ),
          _buildPaginationFooter(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ContentController controller) {
    final state = controller.reelFeed!.loadingState.value;
    final hasItems = controller.contents.isNotEmpty;

    if (hasItems &&
        (state == LoadingState.loaded || state == LoadingState.loading)) {
      return _buildFeed(context, controller);
    }

    switch (state) {
      case LoadingState.initial:
      case LoadingState.loading:
        return const ColoredBox(
          color: _background,
          child: Center(child: CustomLoader()),
        );
      case LoadingState.offline:
        return _emptyState(
          controller,
          'You are offline. Connect to the internet to load content.',
        );
      case LoadingState.error:
        return _emptyState(
          controller,
          'Unable to load content. Pull down to retry.',
        );
      case LoadingState.loaded:
        return _emptyState(controller);
    }
  }

  Widget _buildFeed(BuildContext context, ContentController controller) {
    return RefreshIndicator(
      backgroundColor: _background,
      color: AppColors.primary,
      edgeOffset: MediaQuery.paddingOf(context).top + 96.h,
      onRefresh: controller.refresh,
      notificationPredicate: (n) =>
          controller.currentReelIndex.value == 0 && n.depth == 0,
      child: const ContentsReelPageView(),
    );
  }

  Widget _buildPaginationFooter(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom + 96.h,
      child: Obx(() {
        final controller = ContentController.to;
        final feed = controller.reelFeed!;

        if (feed.feed.loadMoreFailed.value) {
          return Center(
            child: GestureDetector(
              onTap: controller.retryPagination,
              child: CustomContainer(
                color: AppColors.backgroundLight.withValues(alpha: 0.92),
                radiusAll: 999.r,
                paddingHorizontal: 14.w,
                paddingVertical: 8.h,
                child: CustomText(
                  text: 'Tap to retry',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        if (!controller.showPaginationLoader) {
          return const SizedBox.shrink();
        }

        return Center(
          child: CustomContainer(
            color: AppColors.backgroundLight.withValues(alpha: 0.92),
            radiusAll: 999.r,
            paddingHorizontal: 14.w,
            paddingVertical: 8.h,
            child: const CustomLoader(),
          ),
        );
      }),
    );
  }

  Widget _emptyState(ContentController controller, [String? message]) {
    return EmptyDataWidget(
      message: message ?? 'No content available',
      messageColor: AppColors.textWhite,
      onRefresh: controller.refresh,
    );
  }

  void _openSearch(BuildContext context, ContentController controller) {
    showSearch(
      context: context,
      delegate: SearchScreen(
        hintText: 'Search default exercises...',
        onSearch: (query) async {
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
