import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
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
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
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
  late final Player reelPlayer;
  late final VideoController reelVideoController;

  final RxInt currentReelIndex = 0.obs;
  final RxBool isReelLoading = false.obs;
  final RxString reelMediaError = ''.obs;
  final RxBool isReelPlaying = true.obs;

  Worker? _navTabWorker;
  int? _loadedReelIndex;

  static const int _reelPaginationThreshold = 3;

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
    _initReelPlayer();
    _listenBottomNavVisibility();

    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  void _initReelPlayer() {
    reelPlayer = Player(
      configuration: const PlayerConfiguration(libass: true),
    );
    reelVideoController = VideoController(
      reelPlayer,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );
  }

  void _listenBottomNavVisibility() {
    final navController = Get.find<BottomNavBarController>();
    _navTabWorker = ever<int>(navController.selectedIndexRx, (index) {
      if (index == BottomNavBarController.contentsTabIndex) {
        playReelAt(currentReelIndex.value);
      } else {
        pauseReel();
      }
    });
  }

  Future<void> onReelPageChanged(int index) async {
    currentReelIndex.value = index;
    await playReelAt(index);
    _maybeLoadMoreReels(index);
  }

  void _maybeLoadMoreReels(int index) {
    if (contents.isEmpty) return;
    if (index < contents.length - _reelPaginationThreshold) return;
    if (!contentList.canLoadMore) return;
    contentList.loadMore();
  }

  Future<void> playReelAt(int index) async {
    if (Get.find<BottomNavBarController>().selectedIndex !=
        BottomNavBarController.contentsTabIndex) {
      return;
    }

    if (index < 0 || index >= contents.length) {
      await reelPlayer.pause();
      isReelPlaying.value = false;
      return;
    }

    if (_loadedReelIndex == index && reelMediaError.value.isEmpty) {
      await reelPlayer.play();
      isReelPlaying.value = true;
      return;
    }

    final content = contents[index];
    final media = ContentMediaResolver.mediaFromContent(content);
    if (media == null) {
      reelMediaError.value = 'No video available for this content.';
      _loadedReelIndex = index;
      isReelPlaying.value = false;
      return;
    }

    isReelLoading.value = true;
    reelMediaError.value = '';

    try {
      await reelPlayer.open(media);
      _loadedReelIndex = index;
      isReelPlaying.value = true;
    } catch (error) {
      reelMediaError.value = 'Unable to play this video.';
      if (kDebugMode) debugPrint('playReelAt error: $error');
    } finally {
      isReelLoading.value = false;
    }
  }

  Future<void> pauseReel() async {
    await reelPlayer.pause();
    isReelPlaying.value = false;
  }

  Future<void> toggleReelPlayback() async {
    if (isReelPlaying.value) {
      await pauseReel();
    } else {
      await reelPlayer.play();
      isReelPlaying.value = true;
    }
  }

  Future<void> openContentInFeed(ContentModel content) async {
    final existingIndex = contents.indexWhere((item) => item.id == content.id);
    final targetIndex = existingIndex >= 0 ? existingIndex : 0;

    if (existingIndex < 0) {
      contentList.items.insert(0, content);
    }

    currentReelIndex.value = targetIndex;
    _loadedReelIndex = null;

    if (pageController.hasClients) {
      pageController.jumpToPage(targetIndex);
    }

    await playReelAt(targetIndex);
  }

  void _resetReelPosition() {
    currentReelIndex.value = 0;
    _loadedReelIndex = null;
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

  Future<void> _loadData({bool showFullLoader = true}) async {
    try {
      if (!_connectivityService.isConnected.value) {
        _loadingState.value = LoadingState.offline;
        return;
      }

      if (showFullLoader) {
        _loadingState.value = LoadingState.loading;
      }

      await contentList.loadFirst();
      _loadingState.value = LoadingState.loaded;
      _resetReelPosition();
      await playReelAt(0);
    } on AppException catch (e) {
      _loadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('fetchContents error: $e');
    } catch (e) {
      _loadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('fetchContents error: $e');
    }
  }

  Future<void> changeTab(ContentTab tab) async {
    if (activeTab.value == tab) return;
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
    _selectedCategoryId.value = categoryId;
    _resetReelPosition();
    await _loadData(showFullLoader: false);
  }

  @override
  Future<void> refresh() =>
      contentList.refreshWith(() => _loadData(showFullLoader: false));

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

      await _loadData(showFullLoader: false);
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
      await _loadData();
      if (contents.isNotEmpty) {
        final nextIndex = currentReelIndex.value.clamp(0, contents.length - 1);
        currentReelIndex.value = nextIndex;
        _loadedReelIndex = null;
        if (pageController.hasClients) {
          pageController.jumpToPage(nextIndex);
        }
        await playReelAt(nextIndex);
      }
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _deleteLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('deleteContent error: $e');
    }
  }

  @override
  void onClose() {
    _navTabWorker?.dispose();
    pageController.dispose();
    reelPlayer.dispose();
    searchController.dispose();
    contentList.dispose();
    super.onClose();
  }
}
