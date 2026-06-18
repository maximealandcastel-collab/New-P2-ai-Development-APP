import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
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
  int _currentPage = 1;
  final int _limit = 10;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasMore = true.obs;

  bool get isLoadingMore => _isLoadingMore.value;

  bool get hasMore => _hasMore.value && !_isLoadingMore.value;

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
    if (_scrollController == null) return;
    final position = _scrollController!.position;
    if (position.pixels >= position.maxScrollExtent - 200 &&
        !_isLoadingMore.value &&
        hasMore) {
      _loadMore();
    }
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
        await _service.fetchPolls(1, _limit, search: searchController.text);
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
    if (_isLoadingMore.value || !hasMore) return;

    try {
      _isLoadingMore.value = true;
      _currentPage++;

      final newPolls = await _service.fetchMorePolls(_currentPage, _limit);

      if (newPolls.isNotEmpty) {
        _trainers.addAll(newPolls);
        if (newPolls.length < _limit) _hasMore.value = false;
      } else {
        _hasMore.value = false;
      }
    } on AppException catch (e) {
      _currentPage--;
      if (kDebugMode) debugPrint('Load more error: $e');
    } catch (e) {
      _currentPage--;
      if (kDebugMode) debugPrint('Unexpected error: ${e.toString()}');
    } finally {
      _isLoadingMore.value = false;
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
    _currentPage = 1;
    _hasMore.value = true;
    await _loadData();
  }

  // ─── Poll Details ─────────────────────────────────────────────────────────
  Future<void> fetchPollDetails(
    String trainerID, {
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        _detailsLoadingState.value = LoadingState.loading;
      }
      final poll = await _service.trainerDetails(trainerID);
      _trainerDetails.value = poll;
      _detailsLoadingState.value = LoadingState.loaded;
    } catch (e) {
      _detailsLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('fetchDetails error: $e');
    }
  }

  // ─── Submit Answer ────────────────────────────────────────────────────────
  Future<void> requestTrainer() async {
    try {
      _requestLoadingState.value = LoadingState.loading;
      await _service.trainerRequest(
        trainerId: '',
        note: noteTEController.text.trim(),
      );
      _requestLoadingState.value = LoadingState.loaded;
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
