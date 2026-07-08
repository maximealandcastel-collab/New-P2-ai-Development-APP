import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/search_service.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/contents/core/reel_player_pool.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/domain/services/content_service.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';

enum ContentTab {
  defaultContent,
  myTrainer,
}

class ContentController extends GetxController with PaginatedLoaderUi {
  ContentController({
    required ContentService service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  final ContentService _service;
  final ConnectivityService _connectivityService;

  static ContentController get to => Get.find();

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _deleteLoadingState = LoadingState.initial.obs;
  final RxnString _selectedCategoryId = RxnString();
  final RxBool isSubmittingContent = false.obs;
  final RxDouble submitProgress = 0.0.obs;
  final RxString submitMessage = ''.obs;

  final Rx<ContentTab> activeTab = ContentTab.defaultContent.obs;

  final searchController = TextEditingController();
  late final SearchService<ContentModel> search;

  LoadingState get loadingState => _loadingState.value;
  LoadingState get deleteLoadingState => _deleteLoadingState.value;
  String? get selectedCategoryId => _selectedCategoryId.value;

  late final PaginatedList<ContentModel> contentList;

  List<ContentModel> get contents => contentList.items;

  late final PageController pageController;
  late final ReelPlayerPool _reelPool;

  final RxInt currentReelIndex = 0.obs;
  final RxInt reelMediaRevision = 0.obs;
  final RxString reelMediaError = ''.obs;
  final RxBool isReelPlaying = true.obs;

  Worker? _navTabWorker;
  Worker? _connectivityWorker;
  bool _isClosed = false;
  int _reelSyncGeneration = 0;
  bool _isHandlingReelCompletion = false;

  static const int _reelPaginationThreshold = 3;
  final Map<String, List<ContentModel>> _contentCache = {};

  @override
  LoadingState get paginationContentState => loadingState;

  @override
  PaginatedList<dynamic> get paginatedList => contentList;

  @override
  void onInit() {
    super.onInit();

    final isTrainer = Get.find<ProfileController>().userData?.role == 'trainer';
    activeTab.value =
        isTrainer ? ContentTab.myTrainer : ContentTab.defaultContent;

    contentList = PaginatedList<ContentModel>(
      limit: 10,
      fetchPage: _fetchContentPage,
    );
    search = SearchService(fetcher: _fetchSearch);
    pageController = PageController();
    _reelPool = ReelPlayerPool(
      onStateChanged: () {
        if (!_isClosed) reelMediaRevision.value++;
      },
      onReelCompleted: _onReelCompleted,
    );
    pageController.addListener(_onPageScroll);
    _listenBottomNavVisibility();

    _connectivityWorker = ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected && !_isClosed) _loadData();
    });
    _loadData();
  }

  VideoController? reelVideoControllerFor(int index) =>
      _reelPool.videoControllerFor(index);

  bool isReelReady(int index) => _reelPool.isReady(index);

  bool isReelOpening(int index) => _reelPool.isOpening(index);

  void _onPageScroll() {
    if (_isClosed || !pageController.hasClients) return;
    if (_loadingState.value != LoadingState.loaded || contents.isEmpty) {
      return;
    }

    final page = pageController.page;
    if (page == null) return;

    final index = page.round().clamp(0, contents.length - 1);
    if (index == currentReelIndex.value) return;

    unawaited(_activateReelAt(index));
  }

  Future<void> _activateReelAt(int index) async {
    if (_isClosed) return;

    if (Get.find<BottomNavBarController>().selectedIndex !=
        BottomNavBarController.contentsTabIndex) {
      return;
    }

    if (_loadingState.value != LoadingState.loaded) return;
    if (index < 0 || index >= contents.length) return;

    currentReelIndex.value = index;
    reelMediaError.value = _reelPool.errorFor(index);
    final generation = ++_reelSyncGeneration;

    try {
      await _reelPool.sync(index: index, contents: contents);
      if (_isClosed || generation != _reelSyncGeneration) return;

      reelMediaError.value = _reelPool.errorFor(index);
      isReelPlaying.value = _reelPool.isReady(index);
      reelMediaRevision.value++;
      _maybeLoadMoreReels(index);
    } catch (error) {
      if (kDebugMode) debugPrint('_activateReelAt error: $error');
    }
  }

  void _listenBottomNavVisibility() {
    final navController = Get.find<BottomNavBarController>();
    _navTabWorker = ever<int>(navController.selectedIndexRx, (index) {
      if (_isClosed) return;
      if (index == BottomNavBarController.contentsTabIndex) {
        _schedulePlayReelAt(currentReelIndex.value);
      } else {
        pauseReel();
      }
    });
  }

  void _schedulePlayReelAt(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isClosed) return;
      unawaited(_activateReelAt(index));
    });
  }

  Future<void> onReelPageChanged(int index) async {
    if (index == currentReelIndex.value) {
      _maybeLoadMoreReels(index);
      return;
    }
    await _activateReelAt(index);
  }

  void _maybeLoadMoreReels(int index) {
    if (contents.isEmpty) return;
    if (index < contents.length - _reelPaginationThreshold) return;
    if (!contentList.canLoadMore) return;
    contentList.loadMore();
  }

  void _onReelCompleted() {
    if (_isClosed || !pageController.hasClients || _isHandlingReelCompletion) {
      return;
    }

    if (Get.find<BottomNavBarController>().selectedIndex !=
        BottomNavBarController.contentsTabIndex) {
      return;
    }

    _isHandlingReelCompletion = true;

    final currentIndex = currentReelIndex.value;
    final nextIndex = currentIndex + 1;

    if (nextIndex < contents.length) {
      unawaited(
        _advanceToReel(nextIndex).whenComplete(_resetReelCompletionHandling),
      );
      return;
    }

    if (contentList.canLoadMore) {
      contentList.loadMore().then((_) {
        if (_isClosed || !pageController.hasClients) {
          _resetReelCompletionHandling();
          return;
        }
        final loadedNextIndex = currentReelIndex.value + 1;
        if (loadedNextIndex < contents.length) {
          unawaited(
            _advanceToReel(loadedNextIndex)
                .whenComplete(_resetReelCompletionHandling),
          );
        } else if (contents.length > 1) {
          unawaited(
            _advanceToReel(0).whenComplete(_resetReelCompletionHandling),
          );
        } else {
          unawaited(
            _replayCurrentReel().whenComplete(_resetReelCompletionHandling),
          );
        }
      });
      return;
    }

    if (contents.length > 1) {
      unawaited(
        _advanceToReel(0).whenComplete(_resetReelCompletionHandling),
      );
    } else {
      unawaited(
        _replayCurrentReel().whenComplete(_resetReelCompletionHandling),
      );
    }
  }

  void _resetReelCompletionHandling() {
    _isHandlingReelCompletion = false;
  }

  Future<void> _advanceToReel(int index) async {
    if (_isClosed || !pageController.hasClients) return;
    if (index < 0 || index >= contents.length) return;

    await pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _replayCurrentReel() async {
    if (_isClosed) return;
    isReelPlaying.value = true;
    await _reelPool.replayActive();
  }

  Future<void> pauseReel() async {
    await _reelPool.pauseActive();
    if (!_isClosed) isReelPlaying.value = false;
  }

  Future<void> toggleReelPlayback() async {
    if (_isClosed) return;
    if (isReelPlaying.value) {
      await pauseReel();
    } else {
      await _reelPool.playActive();
      if (!_isClosed) isReelPlaying.value = true;
    }
  }

  void _resetReelPosition() {
    currentReelIndex.value = 0;
    reelMediaError.value = '';
    unawaited(_reelPool.reset());
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
  }

  Future<List<ContentModel>> _fetchContentPage(int page, int limit) async {
    if (activeTab.value == ContentTab.defaultContent) {
      return _service.fetchDefaultContent(
        page: page,
        limit: 20,
      );
    } else {
      return _service.fetchMyContent(
        categoryId: _selectedCategoryId.value,
        page: page,
        limit: limit,
      );
    }
  }

  String _cacheKey(ContentTab tab, String? categoryId) {
    if (tab == ContentTab.defaultContent) return 'default';
    return categoryId == null ? 'myTrainer:all' : 'myTrainer:$categoryId';
  }

  List<ContentModel> _getCachedContents(String key) =>
      List<ContentModel>.from(_contentCache[key] ?? const []);

  void _cacheForTab(
    ContentTab tab,
    String? categoryId,
    List<ContentModel> items,
  ) {
    _contentCache[_cacheKey(tab, categoryId)] =
        List<ContentModel>.from(items);
  }

  void _cacheCurrentTab() {
    _cacheForTab(
      activeTab.value,
      _selectedCategoryId.value,
      contentList.items,
    );
  }

  void _invalidateCurrentCache() {
    _contentCache.remove(
      _cacheKey(activeTab.value, _selectedCategoryId.value),
    );
  }

  Future<void> _reloadFeedFromApi() async {
    if (!_connectivityService.isConnected.value) return;

    await contentList.loadFirst();
    if (_isClosed) return;

    _cacheCurrentTab();
    _loadingState.value = LoadingState.loaded;
    _resetReelPosition();
    _schedulePlayReelAt(0);
  }

  Future<void> _loadData({bool showFullLoader = true}) async {
    try {
      final isOnline = _connectivityService.isConnected.value;
      final cacheKey = _cacheKey(activeTab.value, _selectedCategoryId.value);
      final hasCachedData = _contentCache.containsKey(cacheKey);
      final cached = _getCachedContents(cacheKey);

      if (showFullLoader) {
        if (hasCachedData) {
          contentList.items.value = cached;
          _loadingState.value = LoadingState.loaded;
          _resetReelPosition();
          _schedulePlayReelAt(0);
        } else {
          contentList.items.clear();
          _loadingState.value = LoadingState.loading;
          unawaited(pauseReel());
        }
      }

      if (!isOnline) {
        if (!hasCachedData && contents.isEmpty) {
          _loadingState.value = LoadingState.offline;
        }
        return;
      }

      await contentList.loadFirst();
      if (_isClosed) return;
      _cacheCurrentTab();
      _loadingState.value = LoadingState.loaded;
      _resetReelPosition();
      _schedulePlayReelAt(0);
    } on AppException catch (e) {
      if (!_contentCache.containsKey(
        _cacheKey(activeTab.value, _selectedCategoryId.value),
      )) {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('fetchContents error: $e');
    } catch (e) {
      if (!_contentCache.containsKey(
        _cacheKey(activeTab.value, _selectedCategoryId.value),
      )) {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('fetchContents error: $e');
    }
  }

  Future<void> changeTab(ContentTab tab) async {
    if (activeTab.value == tab) return;
    _cacheCurrentTab();
    activeTab.value = tab;

    _selectedCategoryId.value = null;
    searchController.clear();
    search.clear();
    _resetReelPosition();

    await _loadData();
  }

  Future<List<ContentModel>> _fetchSearch(String query) async {
    if (!_connectivityService.isConnected.value) return [];
    return _service.fetchDefaultContent(
      search: query,
      page: 1,
      limit: 20,
    );
  }

  Future<void> selectCategory(String? categoryId) async {
    if (_selectedCategoryId.value == categoryId) return;
    _cacheCurrentTab();
    _selectedCategoryId.value = categoryId;
    _resetReelPosition();
    await _loadData();
  }

  @override
  Future<void> refresh() async {
    await pauseReel();
    _invalidateCurrentCache();
    await contentList.refreshWith(_reloadFeedFromApi);
  }

  Future<void> createOrUpdateContent({
    required Map<String, dynamic> fields,
    File? video,
    File? thumbnail,
    String? contentId,
    required bool isEditMode,
  }) async {
    isSubmittingContent.value = true;
    submitProgress.value = 0;
    submitMessage.value =
        isEditMode ? 'Updating content...' : 'Posting content...';

    BottomNavBarController.to.goToContentsTab();

    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    }

    void onProgress(int sent, int total) {
      if (total > 0) submitProgress.value = sent / total;
    }

    try {
      if (isEditMode && contentId != null) {
        await _service.updateContent(
          contentId: contentId,
          fields: fields,
          video: video,
          thumbnail: thumbnail,
          onSendProgress: onProgress,
        );
        ToastMessageHelper.show('Content updated successfully');
      } else {
        await _service.createContent(
          fields: fields,
          video: video,
          thumbnail: thumbnail,
          onSendProgress: onProgress,
        );
        ToastMessageHelper.show('Content posted successfully');
      }

      _invalidateCurrentCache();
      await _reloadFeedFromApi();
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('createOrUpdateContent error: $e');
    } finally {
      isSubmittingContent.value = false;
      submitProgress.value = 0;
      submitMessage.value = '';
    }
  }

  Future<void> deleteContent(String contentId) async {
    try {
      _deleteLoadingState.value = LoadingState.loading;
      await _service.deleteContent(contentId);
      _deleteLoadingState.value = LoadingState.loaded;
      if (Get.isDialogOpen ?? false) Get.back();
      _invalidateCurrentCache();
      await _reloadFeedFromApi();
      if (contents.isNotEmpty) {
        final nextIndex = currentReelIndex.value.clamp(0, contents.length - 1);
        currentReelIndex.value = nextIndex;
        unawaited(_reelPool.reset());
        if (pageController.hasClients) {
          pageController.jumpToPage(nextIndex);
        }
        _schedulePlayReelAt(nextIndex);
      }
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _deleteLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('deleteContent error: $e');
    }
  }

  @override
  void onClose() {
    _isClosed = true;
    pageController.removeListener(_onPageScroll);
    _navTabWorker?.dispose();
    _connectivityWorker?.dispose();
    pageController.dispose();
    searchController.dispose();
    contentList.dispose();
    unawaited(_reelPool.dispose());
    super.onClose();
  }
}
