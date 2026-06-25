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
import 'package:pler_to_pler_app/features/trainer/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/trainer/contents/domain/services/content_service.dart';

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
  final Rx<LoadingState> _submitLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _deleteLoadingState = LoadingState.initial.obs;
  final RxnString _selectedCategoryId = RxnString();

  LoadingState get loadingState => _loadingState.value;
  LoadingState get submitLoadingState => _submitLoadingState.value;
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
    contentList = PaginatedList<ContentModel>(
      limit: 10,
      fetchPage: _fetchContentPage,
    );
    contentList.initScroll();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  Future<List<ContentModel>> _fetchContentPage(int page, int limit) async {
    return _service.fetchMyContent(
      categoryId: _selectedCategoryId.value,
      page: page,
      limit: limit,
    );
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

  Future<void> selectCategory(String? categoryId) async {
    if (_selectedCategoryId.value == categoryId) return;
    _selectedCategoryId.value = categoryId;
    await _loadData();
  }

  @override
  Future<void> refresh() =>
      contentList.refreshWith(() => _loadData(showFullLoader: false));

  Future<bool> submitContent({
    required Map<String, dynamic> data,
    ContentModel? editingContent,
  }) async {
    try {
      _submitLoadingState.value = LoadingState.loading;

      if (editingContent?.id != null) {
        await _service.updateContent(
          contentId: editingContent!.id!,
          data: data,
        );
      } else {
        await _service.createContent(data);
      }

      _submitLoadingState.value = LoadingState.loaded;
      await _loadData();
      Get.back(result: true);
      return true;
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _submitLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('submitContent error: $e');
      return false;
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
    contentList.dispose();
    super.onClose();
  }
}
