import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/core/services/search_service.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';
import 'package:pler_to_pler_app/features/trainer/request/domain/services/request_service.dart';

class RequestsController extends GetxController with PaginatedLoaderUi {
  RequestsController({
    required RequestService service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  final RequestService _service;
  final ConnectivityService _connectivityService;

  static RequestsController get to => Get.find();

  final searchController = TextEditingController();
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final RxSet<String> _actionLoadingIds = <String>{}.obs;

  LoadingState get loadingState => _loadingState.value;
  List<TrainerRequestModel> get requests => requestsList.items;

  ScrollController? get scrollController => requestsList.scrollController;

  late final PaginatedList<TrainerRequestModel> requestsList;
  late final SearchService<TrainerRequestModel> search;

  @override
  LoadingState get paginationContentState => loadingState;

  @override
  PaginatedList<dynamic> get paginatedList => requestsList;

  @override
  void onInit() {
    super.onInit();
    requestsList = PaginatedList<TrainerRequestModel>(
      limit: 10,
      fetchPage: _fetchRequestsPage,
    );
    search = SearchService(fetcher: _fetchSearch);
    requestsList.initScroll();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  Future<List<TrainerRequestModel>> _fetchRequestsPage(
    int page,
    int limit,
  ) async {
    _service.updateFilters(search: searchController.text.trim());

    if (page == 1) {
      await _service.fetchRequests(page, limit);
      return _service.getCachedRequests();
    }
    return _service.fetchMoreRequests(page, limit);
  }

  Future<void> _loadData({bool showFullLoader = true}) async {
    try {
      _service.updateFilters(search: searchController.text.trim());

      final cached = _service.getCachedRequests();
      final hasUsableCache = cached.isNotEmpty;
      final isOnline = _connectivityService.isConnected.value;

      if (showFullLoader) {
        if (hasUsableCache) {
          requestsList.items.value = cached;
          _loadingState.value = LoadingState.loaded;
        } else {
          requestsList.items.clear();
          _loadingState.value = LoadingState.loading;
        }
      }

      if (!isOnline) {
        if (!hasUsableCache) _loadingState.value = LoadingState.offline;
        return;
      }

      try {
        await requestsList.loadFirst();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasUsableCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch requests error: $e');
      }
    } catch (e) {
      final cached = _service.getCachedRequests();
      if (cached.isNotEmpty) {
        requestsList.items.value = cached;
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected requests error: $e');
    }
  }

  Future<List<TrainerRequestModel>> _fetchSearch(String query) async {
    final fromCache = _service
        .getCachedRequests()
        .where(
          (request) =>
              request.clientName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    if (fromCache.isNotEmpty) return fromCache;
    if (!_connectivityService.isConnected.value) return [];

    _service.updateFilters(search: query);
    await _service.fetchRequests(1, 20);
    return _service.getCachedRequests();
  }

  void applySearchQuery(String query) {
    searchController.text = query;
    _loadData(showFullLoader: false);
  }

  bool isActionLoading(String requestId) => _actionLoadingIds.contains(requestId);

  Future<void> acceptRequest(TrainerRequestModel request) async {
    final requestId = request.id;
    if (requestId == null || isActionLoading(requestId)) return;

    try {
      _actionLoadingIds.add(requestId);
      await _service.acceptRequest(requestId);
      ToastMessageHelper.show('Request accepted');
      await refresh();
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
    } finally {
      _actionLoadingIds.remove(requestId);
    }
  }

  Future<void> rejectRequest(TrainerRequestModel request) async {
    final requestId = request.id;
    if (requestId == null || isActionLoading(requestId)) return;

    try {
      _actionLoadingIds.add(requestId);
      await _service.rejectRequest(requestId);
      ToastMessageHelper.show('Request rejected');
      await refresh();
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
    } finally {
      _actionLoadingIds.remove(requestId);
    }
  }

  Future<void> sendInvoice(TrainerRequestModel request) async {
    final requestId = request.id;
    if (requestId == null || isActionLoading(requestId)) return;

    try {
      _actionLoadingIds.add(requestId);
      await _service.sendInvoice(request);
      ToastMessageHelper.show('Invoice sent successfully');
      await refresh();
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
    } finally {
      _actionLoadingIds.remove(requestId);
    }
  }

  @override
  Future<void> refresh() =>
      requestsList.refreshWith(() => _loadData(showFullLoader: false));

  @override
  void onClose() {
    requestsList.dispose();
    searchController.dispose();
    super.onClose();
  }
}
