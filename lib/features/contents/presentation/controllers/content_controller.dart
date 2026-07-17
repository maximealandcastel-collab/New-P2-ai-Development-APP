import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/search_service.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/domain/services/content_service.dart';
import 'package:pler_to_pler_app/features/contents/reels/presentation/controllers/reel_controller.dart';
import 'package:pler_to_pler_app/features/contents/reels/presentation/controllers/reel_feed_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:preload_page_view/preload_page_view.dart';

enum ContentTab {
  defaultContent,
  myTrainer,
}

/// Orchestrates the contents screen: tabs, CRUD, search, and reels playback.
class ContentController extends GetxController with PaginatedLoaderUi {
  ContentController({
    required ContentService service,
    required ConnectivityService connectivityService,
    ReelController? reelController,
    ReelFeedController? reelFeedController,
  })  : _service = service,
        _connectivityService = connectivityService,
        _reelController = reelController,
        _reelFeedController = reelFeedController;

  final ContentService _service;
  final ConnectivityService _connectivityService;
  ReelController? _reelController;
  ReelFeedController? _reelFeedController;

  static ContentController get to => Get.find();

  final Rx<LoadingState> _deleteLoadingState = LoadingState.initial.obs;
  final RxnString _selectedCategoryId = RxnString();
  final RxBool isSubmittingContent = false.obs;
  final RxDouble submitProgress = 0.0.obs;
  final RxString submitMessage = ''.obs;

  final Rx<ContentTab> activeTab = ContentTab.defaultContent.obs;

  final searchController = TextEditingController();
  late final SearchService<ContentModel> search;

  LoadingState get loadingState =>
      reelFeed?.loadingState.value ?? LoadingState.initial;
  LoadingState get deleteLoadingState => _deleteLoadingState.value;
  String? get selectedCategoryId => _selectedCategoryId.value;

  ReelFeedController? get reelFeed => _reelFeedController;
  ReelController get reel => _reelController ??= Get.find<ReelController>();

  List<ContentModel> get contents => reelFeed?.items ?? const [];

  late final PreloadPageController pageController;

  Worker? _navTabWorker;
  Worker? _connectivityWorker;
  bool _isClosed = false;

  @override
  LoadingState get paginationContentState => loadingState;

  @override
  PaginatedList<dynamic> get paginatedList => reelFeed!.feed;

  @override
  void onInit() {
    super.onInit();

    final isTrainer = Get.find<ProfileController>().userData?.role == 'trainer';
    activeTab.value =
        isTrainer ? ContentTab.myTrainer : ContentTab.defaultContent;

    _reelFeedController ??= ReelFeedController(
      service: _service,
      connectivityService: _connectivityService,
      fetchPage: _fetchContentPage,
    );

    search = SearchService(fetcher: _fetchSearch);
    pageController = PreloadPageController();
    _listenBottomNavVisibility();

    _connectivityWorker = ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected && !_isClosed) {
        _loadData(showFullLoader: contents.isEmpty);
      }
    });
    _loadData();
  }

  // --- Reel playback delegates ---

  RxInt get currentReelIndex => reel.currentIndex;

  void _schedulePlayReelAt(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isClosed) return;
      unawaited(_activateReelAt(index));
    });
  }

  Future<void> _activateReelAt(int index) async {
    if (_isClosed) return;

    if (Get.find<BottomNavBarController>().selectedIndex !=
        BottomNavBarController.contentsTabIndex) {
      return;
    }

    if (loadingState != LoadingState.loaded) return;
    if (index < 0 || index >= contents.length) return;

    await reel.activateAt(index: index, contents: contents);
  }

  void _listenBottomNavVisibility() {
    final navController = Get.find<BottomNavBarController>();
    _navTabWorker = ever<int>(navController.selectedIndexRx, (index) {
      if (_isClosed) return;
      if (index == BottomNavBarController.contentsTabIndex) {
        unawaited(reel.resume(contents: contents));
      } else {
        unawaited(reel.suspend());
      }
    });
  }

  Future<void> onReelPageChanged(int index) async {
    reelFeed?.maybeLoadMore(index);
    await reel.onPageChanged(index: index, contents: contents);
  }

  Future<void> retryPagination() => reelFeed?.retryPagination() ?? Future.value();

  Future<void> pauseReel() => reel.pauseActive(userInitiated: true);

  Future<void> toggleReelPlayback() => reel.togglePlayback();

  void _resetReelPosition() {
    unawaited(reel.reset());
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
  }

  // --- Feed / pagination ---

  Future<List<ContentModel>> _fetchContentPage(int page, int limit) async {
    final feedKey = _cacheKey(activeTab.value, _selectedCategoryId.value);

    if (activeTab.value == ContentTab.defaultContent) {
      return _service.fetchDefaultContent(
        page: page,
        limit: limit,
        feedKey: feedKey,
      );
    }

    return _service.fetchMyContent(
      categoryId: _selectedCategoryId.value,
      page: page,
      limit: limit,
      feedKey: feedKey,
    );
  }

  String _cacheKey(ContentTab tab, String? categoryId) {
    if (tab == ContentTab.defaultContent) return 'default';
    return categoryId == null ? 'myTrainer:all' : 'myTrainer:$categoryId';
  }

  Future<void> _cacheCurrentTab() async {
    await _service.cacheFeed(
      _cacheKey(activeTab.value, _selectedCategoryId.value),
      contents,
    );
  }

  Future<void> _invalidateCurrentCache() async {
    await _service.invalidateFeedCache(
      _cacheKey(activeTab.value, _selectedCategoryId.value),
    );
  }

  Future<void> _reloadFeedFromApi() async {
    await reelFeed!.reloadFromApi(
      cacheKey: _cacheKey(activeTab.value, _selectedCategoryId.value),
      onReloaded: () async {
        if (_isClosed) return;
        _resetReelPosition();
        _schedulePlayReelAt(0);
      },
    );
  }

  Future<void> _loadData({bool showFullLoader = true}) async {
    final cacheKey = _cacheKey(activeTab.value, _selectedCategoryId.value);

    await reelFeed!.load(cacheKey: cacheKey, showFullLoader: showFullLoader);

    if (_isClosed) return;

    if (loadingState == LoadingState.loaded && contents.isNotEmpty) {
      _schedulePlayReelAt(
        reel.currentIndex.value.clamp(0, contents.length - 1),
      );
    } else if (loadingState == LoadingState.loading) {
      unawaited(pauseReel());
    }
  }

  Future<void> changeTab(ContentTab tab) async {
    if (activeTab.value == tab) return;
    await _cacheCurrentTab();
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
      cacheResults: false,
    );
  }

  Future<void> selectCategory(String? categoryId) async {
    if (_selectedCategoryId.value == categoryId) return;
    await _cacheCurrentTab();
    _selectedCategoryId.value = categoryId;
    _resetReelPosition();
    await _loadData();
  }

  @override
  Future<void> refresh() async {
    await pauseReel();
    await reelFeed!.refresh(
      cacheKey: _cacheKey(activeTab.value, _selectedCategoryId.value),
      onBeforeReload: _invalidateCurrentCache,
      onReloaded: () async {},
    );
    _resetReelPosition();
    _schedulePlayReelAt(0);
  }

  @override
  bool get showPaginationLoader =>
      paginationContentState == LoadingState.loaded &&
      (reelFeed?.showPaginationLoader ?? false);

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

      await _invalidateCurrentCache();
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
      await _invalidateCurrentCache();
      await _reloadFeedFromApi();
      if (contents.isNotEmpty) {
        final nextIndex =
            reel.currentIndex.value.clamp(0, contents.length - 1);
        reel.currentIndex.value = nextIndex;
        await reel.playerManager.reset();
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
    _navTabWorker?.dispose();
    _connectivityWorker?.dispose();
    pageController.dispose();
    searchController.dispose();
    reelFeed?.dispose();
    unawaited(reel.disposePlayback());
    super.onClose();
  }
}
