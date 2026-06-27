import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/domain/services/exercise_block_service.dart';

class ExerciseBlockController extends GetxController with PaginatedLoaderUi {
  ExerciseBlockController({
    required ExerciseBlockService service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  final ExerciseBlockService _service;
  final ConnectivityService _connectivityService;

  static ExerciseBlockController get to => Get.find();

  late final PaginatedList<ExerciseBlockModel> blocksList;

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _deleteLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;
  LoadingState get deleteLoadingState => _deleteLoadingState.value;
  List<ExerciseBlockModel> get blocks => blocksList.items;

  @override
  LoadingState get paginationContentState => loadingState;

  @override
  PaginatedList<dynamic> get paginatedList => blocksList;

  @override
  void onInit() {
    super.onInit();
    blocksList = PaginatedList<ExerciseBlockModel>(
      limit: 10,
      fetchPage: _fetchBlocksPage,
    );
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  Future<List<ExerciseBlockModel>> _fetchBlocksPage(int page, int limit) async {
    if (page == 1) {
      await _service.fetchBlocks(page, limit);
      return _service.getCachedBlocks();
    }
    return _service.fetchMoreBlocks(page, limit);
  }

  Future<void> _loadData({bool showFullLoader = true}) async {
    try {
      final cached = _service.getCachedBlocks();
      final hasUsableCache = cached.isNotEmpty;
      final isOnline = _connectivityService.isConnected.value;

      if (showFullLoader) {
        if (hasUsableCache) {
          blocksList.items.value = cached;
          _loadingState.value = LoadingState.loaded;
        } else {
          blocksList.items.clear();
          _loadingState.value = LoadingState.loading;
        }
      }

      if (!isOnline) {
        if (!hasUsableCache) _loadingState.value = LoadingState.offline;
        return;
      }

      try {
        await blocksList.loadFirst();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasUsableCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch blocks error: $e');
      }
    } catch (e) {
      final cached = _service.getCachedBlocks();
      if (cached.isNotEmpty) {
        blocksList.items.value = cached;
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected blocks error: $e');
    }
  }

  @override
  Future<void> refresh() =>
      blocksList.refreshWith(() => _loadData(showFullLoader: false));

  void onEditBlock(ExerciseBlockModel block) {
    ToastMessageHelper.show('Edit ${block.title}');
  }

  void onBlockTap(ExerciseBlockModel block) {
    final blockId = block.id;
    if (blockId == null || blockId.isEmpty) return;

    Get.toNamed(
      AppRoute.exerciseBlockDetailsScreen,
      arguments: block,
    );
  }

  Future<void> deleteBlock(String blockId) async {
    try {
      _deleteLoadingState.value = LoadingState.loading;
      await _service.deleteBlock(blockId);
      blocksList.items.removeWhere((block) => block.id == blockId);
      _deleteLoadingState.value = LoadingState.loaded;
      Get.back(canPop: true);
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _deleteLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('deleteBlock error: $e');
    }
  }

  @override
  void onClose() {
    blocksList.dispose();
    super.onClose();
  }
}
