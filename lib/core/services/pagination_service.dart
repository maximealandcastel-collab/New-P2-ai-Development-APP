import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable pagination helper for list screens.
///
/// Usage:
/// ```dart
/// final pagination = PaginationService();
///
/// void _onScroll() => pagination.handleScroll(_scrollController, _loadMore);
///
/// Future<void> refresh() async {
///   pagination.beginRefresh();
///   pagination.scrollToTop(_scrollController);
///   try {
///     await fetchPage1();
///     pagination.markFirstPageLoaded();
///   } finally {
///     pagination.endRefresh();
///   }
/// }
///
/// Future<void> _loadMore() async {
///   final page = pagination.startLoadMore();
///   if (page == null) return;
///   try {
///     final items = await fetchPage(page);
///     pagination.finishLoadMore(items.length);
///   } catch (_) {
///     pagination.failLoadMore();
///   }
/// }
/// ```
class PaginationService {
  PaginationService({
    this.limit = 10,
    this.scrollThreshold = 200,
  });

  final int limit;
  final double scrollThreshold;

  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isRefreshing = false.obs;

  bool get canLoadMore =>
      hasMore.value && !isLoadingMore.value && !isRefreshing.value;

  void reset() {
    currentPage.value = 1;
    hasMore.value = true;
    isLoadingMore.value = false;
  }

  void beginRefresh() {
    isRefreshing.value = true;
    reset();
  }

  void endRefresh() {
    isRefreshing.value = false;
  }

  void markFirstPageLoaded() {
    currentPage.value = 1;
    hasMore.value = true;
    isLoadingMore.value = false;
  }

  int? startLoadMore() {
    if (!canLoadMore) return null;
    isLoadingMore.value = true;
    currentPage.value++;
    return currentPage.value;
  }

  void finishLoadMore(int itemCount) {
    isLoadingMore.value = false;
    if (itemCount < limit) hasMore.value = false;
  }

  void failLoadMore() {
    if (currentPage.value > 1) currentPage.value--;
    isLoadingMore.value = false;
  }

  bool shouldLoadMore(ScrollController? controller) {
    if (controller == null || !controller.hasClients || !canLoadMore) {
      return false;
    }
    final position = controller.position;
    return position.pixels >= position.maxScrollExtent - scrollThreshold;
  }

  void handleScroll(ScrollController? controller, VoidCallback onLoadMore) {
    if (shouldLoadMore(controller)) onLoadMore();
  }

  void scrollToTop(ScrollController? controller) {
    if (controller?.hasClients ?? false) {
      controller!.jumpTo(0);
    }
  }
}
