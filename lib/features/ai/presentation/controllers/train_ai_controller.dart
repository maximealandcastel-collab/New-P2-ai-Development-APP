import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/ai/data/models/knowledge_pack_model.dart';
import 'package:pler_to_pler_app/features/ai/domain/services/ai_service.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';

class TrainAiController extends GetxController {
  final AiService _aiService;
  final ProfileService _profileService;

  TrainAiController({
    required AiService aiService,
    required ProfileService profileService,
  }) : _aiService = aiService,
       _profileService = profileService;

  static TrainAiController get to => Get.find();

  final formKey = GlobalKey<FormState>();

  final daysPerWeekController = TextEditingController();
  final repRangeMinController = TextEditingController();
  final repRangeMaxController = TextEditingController();
  final restTimeMinController = TextEditingController();
  final restTimeMaxController = TextEditingController();
  final intensityMeasureController = TextEditingController();
  final deloadFrequencyController = TextEditingController();
  final cardioPhilosophyController = TextEditingController();
  final proteinTargetController = TextEditingController();
  final hydrationRuleController = TextEditingController();
  final maintenancePlateController = TextEditingController();
  final weekendStrategyController = TextEditingController();
  final consistencyMethodController = TextEditingController();
  final motivationDropResponseController = TextEditingController();
  final plateauProtocolController = TextEditingController();
  final deloadRulesController = TextEditingController();
  final coachingStyleController = TextEditingController();

  List<String> preferredSplits = [];
  List<String> mustUseExercises = [];
  List<String> avoidExercises = [];
  List<String> accessoryFavorites = [];
  List<String> naturalPhrases = [];
  List<String> neverSayPhrases = [];

  static const int pageCount = 12;

  final _submitState = LoadingState.initial.obs;

  LoadingState get submitState => _submitState.value;

  void setPreferredSplits(List<String> tags) => preferredSplits = tags;

  void setMustUseExercises(List<String> tags) => mustUseExercises = tags;

  void setAvoidExercises(List<String> tags) => avoidExercises = tags;

  void setAccessoryFavorites(List<String> tags) => accessoryFavorites = tags;

  void setNaturalPhrases(List<String> values) => naturalPhrases = values;

  void setNeverSayPhrases(List<String> tags) => neverSayPhrases = tags;

  String _buildRepRanges() {
    final min = repRangeMinController.text.trim();
    final max = repRangeMaxController.text.trim();
    return '$min-$max';
  }

  String _buildRestTimes() {
    final min = restTimeMinController.text.trim();
    final max = restTimeMaxController.text.trim();
    return '$min-$max${max.endsWith('s') ? '' : 's'}';
  }

  Future<String?> _resolveTrainerId() async {
    final cachedId = _profileService.getCachedUserData()?.sId;
    if (cachedId != null && cachedId.isNotEmpty) return cachedId;

    await _profileService.fetchUserProfile();
    return _profileService.getCachedUserData()?.sId;
  }

  bool validateStep(int step) {
    switch (step) {
      case 0:
        final daysPerWeek = int.tryParse(daysPerWeekController.text.trim());
        if (daysPerWeek == null || daysPerWeek < 1 || daysPerWeek > 7) {
          ToastMessageHelper.show('Enter days per week between 1 and 7');
          return false;
        }
        if (preferredSplits.isEmpty) {
          ToastMessageHelper.show('Please add at least one preferred split');
          return false;
        }
        return true;
      case 1:
        final repMin = int.tryParse(repRangeMinController.text.trim());
        final repMax = int.tryParse(repRangeMaxController.text.trim());
        if (repMin == null || repMin < 1) {
          ToastMessageHelper.show('Enter valid min reps (e.g. 8)');
          return false;
        }
        if (repMax == null || repMax < 1 || repMax <= repMin) {
          ToastMessageHelper.show(
            'Enter valid max reps greater than min (e.g. 20)',
          );
          return false;
        }
        return true;
      case 2:
        final restMin = int.tryParse(restTimeMinController.text.trim());
        final restMax = int.tryParse(restTimeMaxController.text.trim());
        if (restMin == null || restMin < 1) {
          ToastMessageHelper.show(
            'Enter valid min rest time in seconds (e.g. 60)',
          );
          return false;
        }
        if (restMax == null || restMax < 1 || restMax <= restMin) {
          ToastMessageHelper.show(
            'Enter valid max rest time greater than min (e.g. 90)',
          );
          return false;
        }
        return true;
      case 3:
        if (intensityMeasureController.text.trim().isEmpty) {
          ToastMessageHelper.show('Please select intensity measure');
          return false;
        }
        return true;
      case 4:
        if (mustUseExercises.isEmpty) {
          ToastMessageHelper.show('Please add at least one must use exercise');
          return false;
        }
        return true;
      case 11:
        if (coachingStyleController.text.trim().isEmpty) {
          ToastMessageHelper.show('Please select coaching style');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  bool validateAllSteps() {
    for (var step = 0; step < pageCount; step++) {
      if (!validateStep(step)) return false;
    }
    return true;
  }

  Future<void> submitKnowledgePack() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!validateAllSteps()) return;

    try {
      _submitState.value = LoadingState.loading;

      final trainerId = await _resolveTrainerId();
      if (trainerId == null || trainerId.isEmpty) {
        throw Exception('Trainer ID not found');
      }

      await _aiService.submitKnowledgePack(
        trainerId: trainerId,
        data: KnowledgePackModel(
          daysPerWeek: int.parse(daysPerWeekController.text.trim()),
          preferredSplits: preferredSplits,
          repRanges: _buildRepRanges(),
          restTimes: _buildRestTimes(),
          intensityMeasure: intensityMeasureController.text.trim(),
          deloadFrequency: deloadFrequencyController.text.trim(),
          cardioPhilosophy: cardioPhilosophyController.text.trim(),
          mustUseExercises: mustUseExercises,
          avoidExercises: avoidExercises,
          accessoryFavorites: accessoryFavorites,
          proteinTarget: proteinTargetController.text.trim(),
          hydrationRule: hydrationRuleController.text.trim(),
          maintenancePlate: maintenancePlateController.text.trim(),
          weekendStrategy: weekendStrategyController.text.trim(),
          consistencyMethod: consistencyMethodController.text.trim(),
          motivationDropResponse: motivationDropResponseController.text.trim(),
          plateauProtocol: plateauProtocolController.text.trim(),
          deloadRules: deloadRulesController.text.trim(),
          naturalPhrases: naturalPhrases,
          neverSayPhrases: neverSayPhrases,
          coachingStyle: coachingStyleController.text.trim(),
        ),
      );

      _submitState.value = LoadingState.loaded;
      Get.offAllNamed(AppRoute.bottonNavBar);
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _submitState.value = LoadingState.error;
    }
  }

  @override
  void onClose() {
    daysPerWeekController.dispose();
    repRangeMinController.dispose();
    repRangeMaxController.dispose();
    restTimeMinController.dispose();
    restTimeMaxController.dispose();
    intensityMeasureController.dispose();
    deloadFrequencyController.dispose();
    cardioPhilosophyController.dispose();
    proteinTargetController.dispose();
    hydrationRuleController.dispose();
    maintenancePlateController.dispose();
    weekendStrategyController.dispose();
    consistencyMethodController.dispose();
    motivationDropResponseController.dispose();
    plateauProtocolController.dispose();
    deloadRulesController.dispose();
    coachingStyleController.dispose();
    super.onClose();
  }
}
