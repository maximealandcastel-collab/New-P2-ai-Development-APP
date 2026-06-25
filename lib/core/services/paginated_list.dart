import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

typedef FetchPage<T> = Future<List<T>> Function(int page, int limit);

/// All-in-one pagination — শুধু [fetchPage] দিলেই হবে।
///
/// ```dart
/// late final list = PaginatedList<Item>(
///   fetchPage: (page, limit) => api.getItems(page, limit),
/// );
///
/// @override
/// void onInit() {
///   list.initScroll();
///   list.loadFirst();
/// }
///
/// Future<void> refresh() => list.refreshList();
///
/// @override
/// void onClose() {
///   list.dispose();
///   super.onClose();
/// }
/// ```
class PaginatedList<T> {
  PaginatedList({
    required this.fetchPage,
    this.limit = 10,
    this.scrollThreshold = 200,
    this.postRefreshSuppressMs = 350,
  });

  final FetchPage<T> fetchPage;
  final int limit;
  final double scrollThreshold;
  final int postRefreshSuppressMs;

  final RxList<T> items = <T>[].obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool isRefreshing = false.obs;

  ScrollController? scrollController;
  int _page = 1;
  bool _suppressAutoLoadMore = false;

  bool get canLoadMore =>
      hasMore.value &&
      !isLoadingMore.value &&
      !isRefreshing.value &&
      !_suppressAutoLoadMore;

  void initScroll() {
    scrollController?.dispose();
    scrollController = ScrollController()..addListener(_onScroll);
  }

  void dispose() {
    scrollController?.removeListener(_onScroll);
    scrollController?.dispose();
    scrollController = null;
  }

  Future<void> loadFirst() async {
    _page = 1;
    hasMore.value = true;
    isLoadingMore.value = false;

    final result = await fetchPage(_page, limit);
    items.value = result;
    hasMore.value = result.length >= limit;
  }

  /// Pull-to-refresh — scroll top + page 1 reload.
  Future<void> refreshList() async {
    await _runRefresh(loadFirst);
  }

  /// Custom reload (cache/offline logic থাকলে use করো).
  Future<void> refreshWith(Future<void> Function() reload) async {
    await _runRefresh(reload);
  }

  Future<void> _runRefresh(Future<void> Function() reload) async {
    isRefreshing.value = true;
    _beginRefreshGuard();
    try {
      await reload();
    } finally {
      isRefreshing.value = false;
      _endRefreshGuard();
    }
  }

  void _beginRefreshGuard() {
    _suppressAutoLoadMore = true;
    isLoadingMore.value = false;
    _resetPagination();
    _jumpToTop();
  }

  void _endRefreshGuard() {
    _jumpToTop();
    _scheduleJumpToTop();

    Future<void>.delayed(Duration(milliseconds: postRefreshSuppressMs), () {
      _suppressAutoLoadMore = false;
      _jumpToTop();
      _scheduleJumpToTop();
    });
  }

  void _resetPagination() {
    _page = 1;
    hasMore.value = true;
    isLoadingMore.value = false;
  }

  Future<void> _loadMore() async {
    if (!canLoadMore) return;

    isLoadingMore.value = true;
    _page++;

    try {
      final result = await fetchPage(_page, limit);
      if (result.isNotEmpty) items.addAll(result);
      if (result.length < limit) hasMore.value = false;
    } catch (_) {
      _page--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _onScroll() {
    final controller = scrollController;
    if (controller == null || !controller.hasClients || !canLoadMore) return;

    final position = controller.position;
    if (!position.hasContentDimensions || position.maxScrollExtent <= 0) {
      return;
    }

    if (position.pixels >= position.maxScrollExtent - scrollThreshold) {
      _loadMore();
    }
  }

  void _jumpToTop() {
    final controller = scrollController;
    if (controller == null || !controller.hasClients) return;

    try {
      if (controller.offset != 0) {
        controller.jumpTo(0);
      }
    } catch (_) {}
  }

  void _scheduleJumpToTop() {
    SchedulerBinding.instance.addPostFrameCallback((_) => _jumpToTop());
  }
}
