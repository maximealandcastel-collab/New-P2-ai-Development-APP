import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/pagination_service.dart';
import 'package:pler_to_pler_app/core/services/search_service.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';
import 'package:pler_to_pler_app/features/subscribe/domain/services/subscribe_services.dart';

class SubscribeController extends GetxController {
  final SubscribeServices _service;
  final ConnectivityService _connectivityService;

  static SubscribeController get to => Get.find();

  SubscribeController({
    required SubscribeServices service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;

  final noteTEController = TextEditingController();
  final searchController = TextEditingController();

  final RxInt _selected = 0.obs;

  final RxInt _selectedIndex = 0.obs;

  int get selected => _selected.value;

  int get selectedIndex => _selectedIndex.value;

  set selected(int val) => _selected.value = val;

  void onChange(int index) {
    _selectedIndex.value = index;
  }

  // ─── Loading States ───────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _detailsLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _requestLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;

  LoadingState get detailsLoadingState => _detailsLoadingState.value;

  LoadingState get requestLoadingState => _requestLoadingState.value;

  // ─── Data ─────────────────────────────────────────────────────────────────
  final RxList<FindTrainerModel> _trainers = <FindTrainerModel>[].obs;
  final _trainerDetails = Rxn<TrainerDetailsModel>();

  List<FindTrainerModel> get trainers => _trainers;

  TrainerDetailsModel? get trainerDetails => _trainerDetails.value;

  // ─── Pagination ───────────────────────────────────────────────────────────
  final pagination = PaginationService(limit: 10);

  bool get isLoadingMore => pagination.isLoadingMore.value;

  bool get hasMore => pagination.hasMore.value;

  // ─── Scroll Controller ────────────────────────────────────────────────────
  ScrollController? _scrollController;

  ScrollController? get scrollController => _scrollController;

  late final SearchService<FindTrainerModel> search;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    search = SearchService(fetcher: _fetchSearch);
    _initScrollController();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  // ─── Scroll ───────────────────────────────────────────────────────────────
  void _initScrollController() {
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);
  }

  void _onScroll() {
    pagination.handleScroll(_scrollController, _loadMore);
  }

  // ─── Poll List ────────────────────────────────────────────────────────────
  Future<void> _loadData() async {
    try {
      final hasCache = _service.hasCache();
      final isOnline = _connectivityService.isConnected.value;

      if (hasCache) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }

      if (!isOnline) {
        if (!hasCache) {
          _loadingState.value = LoadingState.offline;
        }
        return;
      }

      try {
        await _service.fetchPolls(1, pagination.limit, search: searchController.text);
        pagination.markFirstPageLoaded();
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch error: $e');
      }
    } catch (e) {
      if (_service.hasCache()) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected error: ${e.toString()}');
    }
  }

  Future<void> _loadMore() async {
    final page = pagination.startLoadMore();
    if (page == null) return;

    try {
      final newPolls = await _service.fetchMorePolls(page, pagination.limit);

      if (newPolls.isNotEmpty) {
        _trainers.addAll(newPolls);
      }
      pagination.finishLoadMore(newPolls.length);
    } on AppException catch (e) {
      pagination.failLoadMore();
      if (kDebugMode) debugPrint('Load more error: $e');
    } catch (e) {
      pagination.failLoadMore();
      if (kDebugMode) debugPrint('Unexpected error: ${e.toString()}');
    }
  }

  void _loadFromCache() {
    _trainers.value = _service.getCachedTrainers();
  }

  Future<List<FindTrainerModel>> _fetchSearch(String query) async {
    final fromCache = _service
        .getCachedTrainers()
        .where(
          (a) => a.name?.toLowerCase().contains(query.toLowerCase()) ?? false,
        )
        .toList();
    if (fromCache.isNotEmpty) return fromCache;
    if (!_connectivityService.isConnected.value) return [];
    await _service.fetchPolls(1, 20, search: query);
    return _service
        .getCachedTrainers()
        .where(
          (a) => a.name?.toLowerCase().contains(query.toLowerCase()) ?? false,
        )
        .toList();
  }

  // ─── Refresh  ──────────────────────────────────────────────────────
  @override
  Future<void> refresh() async {
    pagination.beginRefresh();
    pagination.scrollToTop(_scrollController);
    try {
      await _loadData();
    } finally {
      pagination.endRefresh();
    }
  }

  // ─── Poll Details ─────────────────────────────────────────────────────────
  Future<void> fetchDetails(
    String trainerID, {
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        _trainerDetails.value = null;
        _detailsLoadingState.value = LoadingState.loading;
      }
      final details = await _service.trainerDetails(trainerID);
      _trainerDetails.value = details;
      _detailsLoadingState.value = LoadingState.loaded;
    } catch (e) {
      _detailsLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('fetchDetails error: $e');
    }
  }

  // ─── Submit Answer ────────────────────────────────────────────────────────
  Future<void> requestTrainer(String trainerId) async {
    if(noteTEController.text.isEmpty){
      return ;
    }
    try {
      _requestLoadingState.value = LoadingState.loading;
      await _service.trainerRequest(
        trainerId: trainerId,
        note: noteTEController.text.trim(),
      );
      _requestLoadingState.value = LoadingState.loaded;
      Get.back(canPop: true);
      Get.offAllNamed(AppRoute.bottonNavBar);
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _requestLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint(' error: $e');
    }
  }

  // ─── On Close ─────────────────────────────────────────────────────────────
  @override
  void onClose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    searchController.dispose();
    noteTEController.dispose();
    super.onClose();
  }
}
