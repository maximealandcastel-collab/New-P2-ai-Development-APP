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
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/create_exercise_draft_model.dart';
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
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final countController = TextEditingController();
  final contextController = TextEditingController();
  final exerciseNameController = TextEditingController();
  final exerciseMuscleGroupController = TextEditingController();
  final exerciseDifficultyController = TextEditingController();
  final exerciseEquipmentController = TextEditingController();
  final exerciseSetsController = TextEditingController();
  final exerciseRepsController = TextEditingController();
  final exerciseRestTimeController = TextEditingController();
  final exerciseRpeController = TextEditingController();
  final noBarbellController = TextEditingController();
  final noMachineController = TextEditingController();
  final homeOnlyController = TextEditingController();
  final hotelGymController = TextEditingController();
  final stepInstructionController = TextEditingController();
  final stepTipController = TextEditingController();

  final RxList<String> exerciseTags = <String>[].obs;
  final RxList<ExerciseStepDraftModel> draftSteps =
      <ExerciseStepDraftModel>[].obs;
  final RxList<CreateExerciseDraftModel> draftExercises =
      <CreateExerciseDraftModel>[].obs;

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _deleteLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _generateLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _createLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;
  LoadingState get deleteLoadingState => _deleteLoadingState.value;
  LoadingState get generateLoadingState => _generateLoadingState.value;
  LoadingState get createLoadingState => _createLoadingState.value;
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

  String? _backendValueFromOptions(String selected, List<String> options) {
    if (selected.isEmpty) return null;
    for (final option in options) {
      if (StringFormat.formatLabel(option) == selected) return option;
    }
    return selected;
  }

  String? _selectedExerciseMuscleGroup() =>
      _backendValueFromOptions(
        exerciseMuscleGroupController.text.trim(),
        HelperData.muscleGroupOptions,
      );

  String? _selectedExerciseDifficulty() =>
      _backendValueFromOptions(
        exerciseDifficultyController.text.trim(),
        HelperData.contentDifficultyOptions,
      );

  String? _selectedExerciseEquipment() =>
      _backendValueFromOptions(
        exerciseEquipmentController.text.trim(),
        HelperData.exerciseEquipmentOptions,
      );

  Map<String, String> _buildSubstitutions() {
    final substitutions = <String, String>{};
    void addIfNotEmpty(String key, String value) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) substitutions[key] = trimmed;
    }

    addIfNotEmpty('noBarbell', noBarbellController.text);
    addIfNotEmpty('noMachine', noMachineController.text);
    addIfNotEmpty('homeOnly', homeOnlyController.text);
    addIfNotEmpty('hotelGym', hotelGymController.text);
    return substitutions;
  }

  void clearStepForm() {
    stepInstructionController.clear();
    stepTipController.clear();
    draftSteps.clear();
  }

  void clearExerciseForm() {
    exerciseNameController.clear();
    exerciseMuscleGroupController.clear();
    exerciseDifficultyController.clear();
    exerciseEquipmentController.clear();
    exerciseSetsController.clear();
    exerciseRepsController.clear();
    exerciseRestTimeController.clear();
    exerciseRpeController.clear();
    noBarbellController.clear();
    noMachineController.clear();
    homeOnlyController.clear();
    hotelGymController.clear();
    exerciseTags.clear();
  }

  void clearAddForm() {
    blockNameController.clear();
    descriptionController.clear();
    categoryController.clear();
    draftExercises.clear();
    clearExerciseForm();
    clearStepForm();
  }

  void onExerciseTagsChanged(List<String> tags) {
    exerciseTags.assignAll(tags);
  }

  bool validateExerciseForm() {
    final name = exerciseNameController.text.trim();
    if (name.isEmpty) {
      ToastMessageHelper.show('Please enter exercise name');
      return false;
    }
    if (_selectedExerciseMuscleGroup() == null) {
      ToastMessageHelper.show('Please select muscle group');
      return false;
    }
    if (_selectedExerciseDifficulty() == null) {
      ToastMessageHelper.show('Please select difficulty');
      return false;
    }
    if (_selectedExerciseEquipment() == null) {
      ToastMessageHelper.show('Please select equipment');
      return false;
    }
    final sets = int.tryParse(exerciseSetsController.text.trim());
    if (sets == null || sets < 1) {
      ToastMessageHelper.show('Please enter valid sets');
      return false;
    }
    if (exerciseRepsController.text.trim().isEmpty) {
      ToastMessageHelper.show('Please enter reps');
      return false;
    }
    if (exerciseRestTimeController.text.trim().isEmpty) {
      ToastMessageHelper.show('Please enter rest time');
      return false;
    }
    if (exerciseRpeController.text.trim().isEmpty) {
      ToastMessageHelper.show('Please enter RPE');
      return false;
    }
    return true;
  }

  void onOpenAddExercise() {
    clearExerciseForm();
    clearStepForm();
    Get.toNamed(AppRoute.addExerciseScreen);
  }

  void onOpenExerciseSteps() {
    if (!validateExerciseForm()) return;
    stepInstructionController.clear();
    stepTipController.clear();
    Get.toNamed(AppRoute.addExerciseStepsScreen);
  }

  void doneAddingSteps() {
    addDraftStep();
    Get.back();
  }

  void addDraftStep() {
    final instruction = stepInstructionController.text.trim();
    final tip = stepTipController.text.trim();
    if (instruction.isEmpty) {
      ToastMessageHelper.show('Please enter instruction');
      return;
    }

    draftSteps.add(
      ExerciseStepDraftModel(
        order: draftSteps.length + 1,
        instruction: instruction,
        tip: tip,
      ),
    );
    stepInstructionController.clear();
    stepTipController.clear();
  }

  void removeDraftStep(int index) {
    if (index < 0 || index >= draftSteps.length) return;
    draftSteps.removeAt(index);
    for (var i = 0; i < draftSteps.length; i++) {
      final step = draftSteps[i];
      draftSteps[i] = ExerciseStepDraftModel(
        order: i + 1,
        instruction: step.instruction,
        tip: step.tip,
      );
    }
  }

  void saveExercise() {
    if (!validateExerciseForm()) return;
    if (draftSteps.isEmpty) {
      ToastMessageHelper.show('Please add at least one step');
      return;
    }

    final name = exerciseNameController.text.trim();
    if (draftExercises.any((exercise) => exercise.name == name)) {
      ToastMessageHelper.show('Exercise already added');
      return;
    }

    draftExercises.add(_buildExerciseDraft(draftSteps.toList()));
    clearExerciseForm();
    clearStepForm();
    Get.until(
      (route) => route.settings.name == AppRoute.addExerciseBlockScreen,
    );
    ToastMessageHelper.show('Exercise added');
  }

  CreateExerciseDraftModel _buildExerciseDraft(
    List<ExerciseStepDraftModel> steps,
  ) {
    return CreateExerciseDraftModel(
      name: exerciseNameController.text.trim(),
      muscleGroup: _selectedExerciseMuscleGroup()!,
      difficulty: _selectedExerciseDifficulty()!,
      equipment: _selectedExerciseEquipment()!,
      sets: int.parse(exerciseSetsController.text.trim()),
      reps: exerciseRepsController.text.trim(),
      restTime: exerciseRestTimeController.text.trim(),
      rpe: exerciseRpeController.text.trim(),
      substitutions: _buildSubstitutions(),
      tags: exerciseTags.toList(),
      steps: steps,
    );
  }

  void removeExercise(int index) {
    if (index < 0 || index >= draftExercises.length) return;
    draftExercises.removeAt(index);
  }

  Future<bool> createBlock() async {
    final category = _selectedCategoryBackend();
    if (category == null) return false;

    try {
      _createLoadingState.value = LoadingState.loading;
      await _service.createBlock(
        blockName: blockNameController.text.trim(),
        description: descriptionController.text.trim(),
        category: category,
        exercises: draftExercises.toList(),
      );
      _createLoadingState.value = LoadingState.loaded;
      clearAddForm();
      await refresh();
      ToastMessageHelper.show('Exercise block added successfully');
      return true;
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _createLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('createBlock error: $e');
      return false;
    }
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
    clearAddForm();
    Get.toNamed(AppRoute.addExerciseBlockScreen);
  }

  void onGenerateExercise() {
    clearGenerateForm();
    Get.toNamed(AppRoute.generateExerciseBlockScreen);
  }

  @override
  void onClose() {
    blocksList.dispose();
    blockNameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    countController.dispose();
    contextController.dispose();
    exerciseNameController.dispose();
    exerciseMuscleGroupController.dispose();
    exerciseDifficultyController.dispose();
    exerciseEquipmentController.dispose();
    exerciseSetsController.dispose();
    exerciseRepsController.dispose();
    exerciseRestTimeController.dispose();
    exerciseRpeController.dispose();
    noBarbellController.dispose();
    noMachineController.dispose();
    homeOnlyController.dispose();
    hotelGymController.dispose();
    stepInstructionController.dispose();
    stepTipController.dispose();
    super.onClose();
  }
}
