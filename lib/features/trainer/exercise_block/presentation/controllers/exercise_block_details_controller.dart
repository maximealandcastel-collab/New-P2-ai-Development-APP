import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/domain/services/exercise_block_service.dart';

class ExerciseBlockDetailsController extends GetxController {
  ExerciseBlockDetailsController({
    required this.blockId,
    this.previewBlock,
    required ExerciseBlockService service,
  }) : _service = service;

  final String blockId;
  final ExerciseBlockModel? previewBlock;
  final ExerciseBlockService _service;

  static ExerciseBlockDetailsController get to => Get.find();

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rxn<ExerciseBlockModel> _block = Rxn<ExerciseBlockModel>();

  LoadingState get loadingState => _loadingState.value;
  ExerciseBlockModel? get block => _block.value ?? previewBlock;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final hasPreview = previewBlock != null;

      if (hasPreview) {
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }

      _block.value = await _service.fetchBlockById(blockId);
      _loadingState.value = LoadingState.loaded;
    } on AppException catch (e) {
      if (previewBlock == null) {
        _loadingState.value = LoadingState.error;
      }
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('loadBlockDetails error: $e');
    } catch (e) {
      if (previewBlock != null) {
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('loadBlockDetails error: $e');
    }
  }

  @override
  Future<void> refresh() => loadData();
}
