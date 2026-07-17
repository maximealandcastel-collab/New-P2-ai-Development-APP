import 'dart:async';

import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/domain/services/content_service.dart';

typedef ReelFeedFetchPage = Future<List<ContentModel>> Function(
  int page,
  int limit,
);

/// Handles infinite pagination for the reels feed.
///
/// Separated from playback logic so feed fetching stays testable and reusable.
class ReelFeedController {
  ReelFeedController({
    required ContentService service,
    required ConnectivityService connectivityService,
    required ReelFeedFetchPage fetchPage,
    this.pageSize = 10,
    this.paginationThreshold = 2,
  })  : _service = service,
        _connectivityService = connectivityService,
        _fetchPage = fetchPage;

  final ContentService _service;
  final ConnectivityService _connectivityService;
  final ReelFeedFetchPage _fetchPage;
  final int pageSize;
  final int paginationThreshold;

  final Rx<LoadingState> loadingState = LoadingState.initial.obs;

  late final PaginatedList<ContentModel> feed = PaginatedList<ContentModel>(
    limit: pageSize,
    fetchPage: _fetchPage,
  );

  bool _isInitialLoadInFlight = false;
  int? _lastPaginationIndex;

  List<ContentModel> get items => feed.items;

  bool get showPaginationLoader => feed.showLoadMoreLoader;

  bool get canLoadMore => feed.canLoadMore;

  bool get loadMoreFailed => feed.loadMoreFailed.value;

  /// Loads cached data first (when available), then refreshes from the API.
  Future<void> load({
    required String cacheKey,
    bool showFullLoader = true,
  }) async {
    if (_isInitialLoadInFlight) return;
    _isInitialLoadInFlight = true;
    _lastPaginationIndex = null;

    try {
      final isOnline = _connectivityService.isConnected.value;
      final hasCachedData = _service.hasFeedCache(cacheKey);
      final cached = _service.getCachedFeed(cacheKey);

      if (showFullLoader) {
        if (hasCachedData) {
          feed.items.assignAll(cached);
          loadingState.value = LoadingState.loading;
        } else {
          feed.items.clear();
          loadingState.value = LoadingState.loading;
        }
      }

      if (!isOnline) {
        if (items.isEmpty) {
          loadingState.value =
              hasCachedData ? LoadingState.loaded : LoadingState.offline;
        }
        return;
      }

      await feed.loadFirst();
      await _service.cacheFeed(cacheKey, items);
      loadingState.value =
          items.isEmpty ? LoadingState.error : LoadingState.loaded;
    } on AppException {
      if (items.isNotEmpty) {
        loadingState.value = LoadingState.loaded;
      } else {
        loadingState.value = LoadingState.error;
      }
    } catch (_) {
      if (items.isNotEmpty) {
        loadingState.value = LoadingState.loaded;
      } else {
        loadingState.value = LoadingState.error;
      }
    } finally {
      _isInitialLoadInFlight = false;
    }
  }

  Future<void> reloadFromApi({
    required String cacheKey,
    required Future<void> Function() onReloaded,
  }) async {
    if (!_connectivityService.isConnected.value) return;

    await feed.loadFirst();
    await _service.cacheFeed(cacheKey, items);
    loadingState.value =
        items.isEmpty ? LoadingState.error : LoadingState.loaded;
    _lastPaginationIndex = null;
    await onReloaded();
  }

  Future<void> refresh({
    required String cacheKey,
    required Future<void> Function() onBeforeReload,
    required Future<void> Function() onReloaded,
  }) async {
    await onBeforeReload();
    await _service.invalidateFeedCache(cacheKey);
    _lastPaginationIndex = null;
    await feed.refreshWith(
      () => reloadFromApi(cacheKey: cacheKey, onReloaded: onReloaded),
    );
  }

  /// Triggers pagination when the user nears the end of the feed.
  void maybeLoadMore(int index) {
    if (items.isEmpty) return;

    final triggerIndex = items.length - paginationThreshold;
    if (index < triggerIndex) {
      _lastPaginationIndex = null;
      return;
    }

    if (!canLoadMore) return;

    if (_lastPaginationIndex == index && feed.isLoadingMore.value) {
      return;
    }

    _lastPaginationIndex = index;
    unawaited(loadMore());
  }

  Future<void> loadMore() async {
    if (!canLoadMore) return;

    feed.loadMoreFailed.value = false;
    await feed.loadMore();
    if (!feed.loadMoreFailed.value) {
      _lastPaginationIndex = null;
    }
  }

  Future<void> retryPagination() async {
    if (feed.isLoadingMore.value) return;

    feed.loadMoreFailed.value = false;
    await feed.loadMore();
  }

  void dispose() {
    feed.dispose();
  }
}
