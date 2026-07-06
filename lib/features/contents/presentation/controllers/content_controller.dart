import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/search_service.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
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

  // Tabs selection
  final Rx<ContentTab> activeTab = ContentTab.defaultContent.obs;

  final searchController = TextEditingController();
  late final SearchService<ContentModel> search;

  LoadingState get loadingState => _loadingState.value;
  LoadingState get deleteLoadingState => _deleteLoadingState.value;
  String? get selectedCategoryId => _selectedCategoryId.value;

  late final PaginatedList<ContentModel> contentList;

  List<ContentModel> get contents => contentList.items;
  ScrollController? get scrollController => contentList.scrollController;

  @override
  LoadingState get paginationContentState => loadingState;

  @override
  PaginatedList<dynamic> get paginatedList => contentList;

  @override
  void onInit() {
    super.onInit();
    
    // Set initial active tab based on user role
    final isTrainer = Get.find<ProfileController>().userData?.role == 'trainer';
    activeTab.value = isTrainer ? ContentTab.myTrainer : ContentTab.defaultContent;

    contentList = PaginatedList<ContentModel>(
      limit: 10,
      fetchPage: _fetchContentPage,
    );
    contentList.initScroll();
    search = SearchService(fetcher: _fetchSearch);

    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  Future<List<ContentModel>> _fetchContentPage(int page, int limit) async {
    if (activeTab.value == ContentTab.defaultContent) {
      return _service.fetchDefaultContent(
        page: page,
        limit: 200,
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
    await _loadData();
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
      Get.back(canPop: true);
      await _loadData();
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _deleteLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('deleteContent error: $e');
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    contentList.dispose();
    super.onClose();
  }
}
