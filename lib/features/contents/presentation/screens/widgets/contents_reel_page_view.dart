import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_reel_item.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:preload_page_view/preload_page_view.dart' hide PageScrollPhysics;

/// Keeps scroll position stable when pagination appends items.
class ContentsReelPageView extends StatefulWidget {
  const ContentsReelPageView({super.key});

  @override
  State<ContentsReelPageView> createState() => _ContentsReelPageViewState();
}

class _ContentsReelPageViewState extends State<ContentsReelPageView> {
  Worker? _itemsWorker;
  Worker? _paginationWorker;
  int _itemCount = 0;
  bool _showPaginationPage = false;

  @override
  void initState() {
    super.initState();
    final controller = ContentController.to;
    _syncCounts(controller);

    _itemsWorker = ever<List<ContentModel>>(controller.reelFeed!.feed.items, (_) {
      _syncCounts(controller);
    });

    final feed = controller.reelFeed!.feed;
    _paginationWorker = everAll([
      feed.isLoadingMore,
      feed.loadMoreFailed,
    ], (_) {
      _syncCounts(controller);
    });
  }

  void _syncCounts(ContentController controller) {
    if (!mounted) return;
    final feed = controller.reelFeed!.feed;
    final nextCount = controller.contents.length;
    final nextPaginationPage =
        feed.isLoadingMore.value || feed.loadMoreFailed.value;

    if (nextCount != _itemCount || nextPaginationPage != _showPaginationPage) {
      final wasOnPaginationPage = _showPaginationPage && !nextPaginationPage;

      setState(() {
        _itemCount = nextCount;
        _showPaginationPage = nextPaginationPage;
      });

      if (wasOnPaginationPage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final pageController = controller.pageController;
          if (!pageController.hasClients) return;

          final page = pageController.page?.round() ?? 0;
          if (page >= controller.contents.length) {
            pageController.jumpToPage(
              (controller.contents.length - 1).clamp(0, controller.contents.length - 1),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _itemsWorker?.dispose();
    _paginationWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ContentController.to;
    final pageCount = _itemCount + (_showPaginationPage ? 1 : 0);

    return ColoredBox(
      color: Colors.black,
      child: PreloadPageView.builder(
        controller: controller.pageController,
        scrollDirection: Axis.vertical,
        preloadPagesCount: 1,
        physics: const AlwaysScrollableScrollPhysics(
          parent: PageScrollPhysics(),
        ),
        itemCount: pageCount,
        onPageChanged: controller.onReelPageChanged,
        itemBuilder: (context, index) {
          if (index >= _itemCount) {
            return _buildPaginationPage();
          }

          final content = controller.contents[index];
          return ContentReelItem(
            key: ValueKey(content.id ?? 'content_$index'),
            content: content,
            index: index,
          );
        },
      ),
    );
  }

  Widget _buildPaginationPage() {
    final controller = ContentController.to;
    final feed = controller.reelFeed!.feed;

    return ColoredBox(
      color: Colors.black,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: feed.loadMoreFailed.value
                ? GestureDetector(
                    onTap: controller.retryPagination,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: AppColors.textWhite,
                            size: 20.r,
                          ),
                          SizedBox(width: 8.w),
                          CustomText(
                            text: 'Tap to retry',
                            fontSize: 14.sp,
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  )
                : const CustomLoader(),
          ),
        ),
      ),
    );
  }
}
