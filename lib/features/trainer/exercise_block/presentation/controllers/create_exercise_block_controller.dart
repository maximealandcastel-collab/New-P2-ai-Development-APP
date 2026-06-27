import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/create_exercise_draft_model.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/domain/services/exercise_block_service.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_controller.dart';

class CreateExerciseBlockController extends GetxController {
  CreateExerciseBlockController({
    required ExerciseBlockService service,
    required ExerciseBlockController blocksController,
  })  : _service = service,
        _blocksController = blocksController;

  final ExerciseBlockService _service;
  final ExerciseBlockController _blocksController;

  static CreateExerciseBlockController get to => Get.find();

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

  final exerciseFormKey = GlobalKey<FormState>();
  static const int exercisePageCount = 3;

  final RxList<String> exerciseTags = <String>[].obs;
  final RxList<ExerciseStepDraftModel> draftSteps =
      <ExerciseStepDraftModel>[].obs;
  final RxMap<String, String> draftSubstitutions = <String, String>{}.obs;
  final RxList<CreateExerciseDraftModel> draftExercises =
      <CreateExerciseDraftModel>[].obs;

  final Rx<LoadingState> _generateLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _createLoadingState = LoadingState.initial.obs;

  LoadingState get generateLoadingState => _generateLoadingState.value;
  LoadingState get createLoadingState => _createLoadingState.value;

  static const Map<String, String> substitutionLabels = {
    'noBarbell': 'No barbell',
    'noMachine': 'No machine',
    'homeOnly': 'Home only',
    'hotelGym': 'Hotel gym',
  };

  bool get hasSubstitutions => draftSubstitutions.isNotEmpty;

  String? _selectedCategoryBackend() {
    final selected = categoryController.text.trim();
    if (selected.isEmpty) return null;

    for (final option in HelperData.muscleGroupOptions) {
      if (StringFormat.formatLabel(option) == selected) return option;
    }
    return selected;
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

  void clearGenerateForm() {
    blockNameController.clear();
    categoryController.clear();
    countController.clear();
    contextController.clear();
  }

  void clearSubstitutionForm() {
    noBarbellController.clear();
    noMachineController.clear();
    homeOnlyController.clear();
    hotelGymController.clear();
    draftSubstitutions.clear();
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
    clearSubstitutionForm();
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

  void onAddExerciseBlock() {
    clearAddForm();
    Get.toNamed(AppRoute.addExerciseBlockScreen);
  }

  void onGenerateExercise() {
    clearGenerateForm();
    Get.toNamed(AppRoute.generateExerciseBlockScreen);
  }

  void onOpenAddExercise() {
    clearExerciseForm();
    clearStepForm();
    Get.toNamed(AppRoute.addExerciseScreen);
  }

  bool validateExerciseStep(int step) {
    switch (step) {
      case 0:
        final sets = int.tryParse(exerciseSetsController.text.trim());
        return exerciseNameController.text.trim().isNotEmpty &&
            sets != null &&
            sets >= 1 &&
            exerciseRepsController.text.trim().isNotEmpty &&
            exerciseRestTimeController.text.trim().isNotEmpty &&
            exerciseRpeController.text.trim().isNotEmpty;
      case 1:
        return _selectedExerciseMuscleGroup() != null &&
            _selectedExerciseDifficulty() != null &&
            _selectedExerciseEquipment() != null;
      case 2:
        return draftSteps.isNotEmpty;
      default:
        return true;
    }
  }

  void showExerciseStepValidationMessage(int step) {
    if (step != 2) return;
    ToastMessageHelper.show('Please add at least one step');
  }

  void onOpenExerciseSteps() {
    stepInstructionController.clear();
    stepTipController.clear();
    Get.toNamed(AppRoute.addExerciseStepsScreen);
  }

  bool validateSubstitutionForm() {
    final fields = [
      noBarbellController.text,
      noMachineController.text,
      homeOnlyController.text,
      hotelGymController.text,
    ];
    if (fields.any((value) => value.trim().isEmpty)) {
      ToastMessageHelper.show('Please fill all substitution fields');
      return false;
    }
    return true;
  }

  void onOpenSubstitutions() {
    if (hasSubstitutions) return;
    Get.toNamed(AppRoute.addExerciseSubstitutionsScreen);
  }

  void syncSubstitutionsPreview() {
    draftSubstitutions.assignAll({
      'noBarbell': noBarbellController.text.trim(),
      'noMachine': noMachineController.text.trim(),
      'homeOnly': homeOnlyController.text.trim(),
      'hotelGym': hotelGymController.text.trim(),
    });
  }

  void doneAddingSubstitutions() {
    if (!validateSubstitutionForm()) return;
    syncSubstitutionsPreview();
    Get.back();
  }

  void removeSubstitutions() {
    clearSubstitutionForm();
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
      substitutions: Map<String, String>.from(draftSubstitutions),
      tags: exerciseTags.toList(),
      steps: steps,
    );
  }

  void removeExercise(int index) {
    if (index < 0 || index >= draftExercises.length) return;
    draftExercises.removeAt(index);
  }

  Future<void> createBlock() async {
    final category = _selectedCategoryBackend();
    if (category == null) return;

    try {
      _createLoadingState.value = LoadingState.loading;
      await _service.createBlock(
        blockName: blockNameController.text.trim(),
        description: descriptionController.text.trim(),
        category: category,
        exercises: draftExercises.toList(),
      );
      _createLoadingState.value = LoadingState.loaded;
      Get.back(canPop: true);
      clearAddForm();
      await _blocksController.refresh();
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _createLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('createBlock error: $e');
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
      await _blocksController.refresh();
      return true;
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _generateLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('generateBlock error: $e');
      return false;
    }
  }

  @override
  void onClose() {
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
