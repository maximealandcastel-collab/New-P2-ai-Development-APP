import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
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

  final blockNameController = TextEditingController();
  final categoryController = TextEditingController();
  final countController = TextEditingController();
  final contextController = TextEditingController();

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _deleteLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _generateLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;
  LoadingState get deleteLoadingState => _deleteLoadingState.value;
  LoadingState get generateLoadingState => _generateLoadingState.value;
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

  String? _selectedCategoryBackend() {
    final selected = categoryController.text.trim();
    if (selected.isEmpty) return null;

    for (final option in HelperData.muscleGroupOptions) {
      if (StringFormat.formatLabel(option) == selected) return option;
    }
    return selected;
  }

  void clearGenerateForm() {
    blockNameController.clear();
    categoryController.clear();
    countController.clear();
    contextController.clear();
  }

  Future<bool> generateBlock() async {
    final category = _selectedCategoryBackend();
    final count = int.tryParse(countController.text.trim());

    if (category == null || count == null) return false;

    try {
      _generateLoadingState.value = LoadingState.loading;
      await _service.generateBlock(
        blockName: blockNameController.text.trim(),
        category: category,
        count: count,
        context: contextController.text.trim(),
      );
      _generateLoadingState.value = LoadingState.loaded;
      clearGenerateForm();
      await refresh();
      ToastMessageHelper.show('Exercise block generated successfully');
      return true;
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _generateLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('generateBlock error: $e');
      return false;
    }
  }

  void onEditBlock(ExerciseBlockModel block) {
    ToastMessageHelper.show('Edit ${block.title}');
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

  void onAddExerciseBlock() {
    ToastMessageHelper.show('Add exercise block');
  }

  void onGenerateExercise() {
    clearGenerateForm();
    Get.toNamed(AppRoute.generateExerciseBlockScreen);
  }

  @override
  void onClose() {
    blocksList.dispose();
    blockNameController.dispose();
    categoryController.dispose();
    countController.dispose();
    contextController.dispose();
    super.onClose();
  }
}
