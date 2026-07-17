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
  final RxBool loadMoreFailed = false.obs;

  ScrollController? scrollController;
  ScrollPosition? _scrollPosition;
  bool _ownsScrollController = false;
  int _page = 1;
  bool _suppressAutoLoadMore = false;
  bool _loadMoreInFlight = false;

  bool get canLoadMore =>
      hasMore.value &&
      !isLoadingMore.value &&
      !isRefreshing.value &&
      !_suppressAutoLoadMore;

  bool get showLoadMoreLoader =>
      isLoadingMore.value && !isRefreshing.value;

  void initScroll() {
    scrollController?.removeListener(_onScroll);
    if (_ownsScrollController) scrollController?.dispose();
    scrollController = ScrollController()..addListener(_onScroll);
    _ownsScrollController = true;
  }

  /// [NestedScrollView] / [SliverScaffold] body-te use korar jonno.
  bool handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    final metrics = notification.metrics;
    if (metrics is ScrollPosition) _scrollPosition = metrics;

    if (!canLoadMore) return false;
    if (!metrics.hasContentDimensions || metrics.maxScrollExtent <= 0) {
      return false;
    }

    if (metrics.pixels >= metrics.maxScrollExtent - scrollThreshold) {
      _loadMore();
    }
    return false;
  }

  void dispose() {
    scrollController?.removeListener(_onScroll);
    if (_ownsScrollController) scrollController?.dispose();
    scrollController = null;
    _ownsScrollController = false;
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

  Future<void> loadMore() => _loadMore();

  Future<void> _loadMore() async {
    if (!canLoadMore || _loadMoreInFlight) return;

    _loadMoreInFlight = true;
    isLoadingMore.value = true;
    loadMoreFailed.value = false;
    _page++;

    try {
      final result = await fetchPage(_page, limit);
      if (result.isNotEmpty) items.addAll(result);
      if (result.length < limit) hasMore.value = false;
    } catch (_) {
      _page--;
      loadMoreFailed.value = true;
    } finally {
      isLoadingMore.value = false;
      _loadMoreInFlight = false;
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
    if (controller != null && controller.hasClients) {
      try {
        if (controller.offset != 0) controller.jumpTo(0);
      } catch (_) {}
      return;
    }

    final position = _scrollPosition;
    if (position != null &&
        position.hasPixels &&
        position.hasContentDimensions) {
      try {
        if (position.pixels != 0) position.jumpTo(0);
      } catch (_) {}
    }
  }

  void _scheduleJumpToTop() {
    SchedulerBinding.instance.addPostFrameCallback((_) => _jumpToTop());
  }
}
