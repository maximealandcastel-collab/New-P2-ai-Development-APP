import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/search_service.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';
import 'package:pler_to_pler_app/features/subscribe/domain/services/subscribe_services.dart';

class SubscribeController extends GetxController with PaginatedLoaderUi {
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
  int get selected => _selected.value;
  set selected(int val) => _selected.value = val;

  // ─── Filter state ─────────────────────────────────────────────────────────
  final RxString selectedSpecialty = 'all'.obs;
  final RxString selectedGender    = 'all'.obs;

  // ─── Loading States ───────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState        = LoadingState.initial.obs;
  final Rx<LoadingState> _detailsLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _requestLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState        => _loadingState.value;
  LoadingState get detailsLoadingState => _detailsLoadingState.value;
  LoadingState get requestLoadingState => _requestLoadingState.value;

  // ─── Data ─────────────────────────────────────────────────────────────────
  final _trainerDetails = Rxn<TrainerDetailsModel>();
  TrainerDetailsModel? get trainerDetails => _trainerDetails.value;

  late final PaginatedList<FindTrainerModel> trainersList;
  List<FindTrainerModel> get trainers => trainersList.items;
  ScrollController? get scrollController => trainersList.scrollController;

  @override
  LoadingState get paginationContentState => loadingState;

  @override
  PaginatedList<dynamic> get paginatedList => trainersList;

  late final SearchService<FindTrainerModel> search;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    trainersList = PaginatedList<FindTrainerModel>(
      limit: 50, // Show top 50 — Find Trainer headline shows 1,000+ on app
      fetchPage: _fetchTrainersPage,
    );
    search = SearchService(fetcher: _fetchSearch);
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  /// Direct API fetch — no cache read-back that could serve stale data.
  Future<List<FindTrainerModel>> _fetchTrainersPage(int page, int limit) async {
    final spec        = selectedSpecialty.value == 'all' ? null : selectedSpecialty.value;
    final gen         = selectedGender.value    == 'all' ? null : selectedGender.value;
    final searchQuery = page == 1 ? searchController.text : null;
    return _service.fetchPolls(page, limit,
        search: searchQuery, specialty: spec, gender: gen);
  }

  // ─── Filter ───────────────────────────────────────────────────────────────
  Future<void> filterBy({required String specialty, required String gender}) async {
    if (selectedSpecialty.value == specialty && selectedGender.value == gender) return;
    selectedSpecialty.value = specialty;
    selectedGender.value    = gender;
    trainersList.items.clear();
    await _loadData(showFullLoader: true);
  }

  // ─── Always fetch fresh from API — never serve stale cached data ──────────
  Future<void> _loadData({bool showFullLoader = true}) async {
    try {
      if (showFullLoader) {
        trainersList.items.clear();
        _loadingState.value = LoadingState.loading;
      }

      if (!_connectivityService.isConnected.value) {
        final cached = _service.getCachedTrainers();
        if (cached.isNotEmpty) {
          trainersList.items.value = cached;
          _loadingState.value = LoadingState.loaded;
        } else {
          _loadingState.value = LoadingState.offline;
        }
        return;
      }

      await trainersList.loadFirst();
      _loadingState.value = LoadingState.loaded;
    } on AppException catch (e) {
      final cached = _service.getCachedTrainers();
      if (cached.isNotEmpty) {
        trainersList.items.value = cached;
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('_loadData AppException: $e');
    } catch (e) {
      _loadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('_loadData error: $e');
    }
  }

  Future<List<FindTrainerModel>> _fetchSearch(String query) async {
    if (!_connectivityService.isConnected.value) {
      return _service
          .getCachedTrainers()
          .where((a) => a.name?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();
    }
    return _service.fetchPolls(1, 20, search: query);
  }

  @override
  Future<void> refresh() =>
      trainersList.refreshWith(() => _loadData(showFullLoader: false));

  Future<void> fetchDetails(String trainerID, {bool showLoader = true}) async {
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

  Future<void> requestTrainer(String trainerId) async {
    if (noteTEController.text.isEmpty) return;
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
      if (kDebugMode) debugPrint('requestTrainer error: $e');
    }
  }

  @override
  void onClose() {
    trainersList.dispose();
    searchController.dispose();
    noteTEController.dispose();
    super.onClose();
  }
}
