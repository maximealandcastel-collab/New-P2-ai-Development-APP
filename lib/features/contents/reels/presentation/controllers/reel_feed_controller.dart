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
    this.paginationThreshold = 3,
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

  List<ContentModel> get items => feed.items;

  bool get showPaginationLoader => feed.showLoadMoreLoader;

  bool get canLoadMore => feed.canLoadMore;

  /// Loads cached data first (when available), then refreshes from the API.
  Future<void> load({
    required String cacheKey,
    bool showFullLoader = true,
  }) async {
    try {
      final isOnline = _connectivityService.isConnected.value;
      final hasCachedData = _service.hasFeedCache(cacheKey);
      final cached = _service.getCachedFeed(cacheKey);

      if (showFullLoader) {
        if (hasCachedData) {
          feed.items.value = cached;
          loadingState.value = LoadingState.loaded;
        } else {
          feed.items.clear();
          loadingState.value = LoadingState.loading;
        }
      }

      if (!isOnline) {
        if (!hasCachedData && items.isEmpty) {
          loadingState.value = LoadingState.offline;
        }
        return;
      }

      await feed.loadFirst();
      await _service.cacheFeed(cacheKey, items);
      loadingState.value = LoadingState.loaded;
    } on AppException {
      if (!_service.hasFeedCache(cacheKey)) {
        loadingState.value = LoadingState.error;
      }
    } catch (_) {
      if (!_service.hasFeedCache(cacheKey)) {
        loadingState.value = LoadingState.error;
      }
    }
  }

  Future<void> reloadFromApi({
    required String cacheKey,
    required Future<void> Function() onReloaded,
  }) async {
    if (!_connectivityService.isConnected.value) return;

    await feed.loadFirst();
    await _service.cacheFeed(cacheKey, items);
    loadingState.value = LoadingState.loaded;
    await onReloaded();
  }

  Future<void> refresh({
    required String cacheKey,
    required Future<void> Function() onBeforeReload,
    required Future<void> Function() onReloaded,
  }) async {
    await onBeforeReload();
    await _service.invalidateFeedCache(cacheKey);
    await feed.refreshWith(
      () => reloadFromApi(cacheKey: cacheKey, onReloaded: onReloaded),
    );
  }

  /// Triggers pagination when the user nears the end of the feed.
  void maybeLoadMore(int index) {
    if (items.isEmpty) return;
    if (index < items.length - paginationThreshold) return;
    if (!canLoadMore) return;
    feed.loadMore();
  }

  void dispose() {
    feed.dispose();
  }
}
