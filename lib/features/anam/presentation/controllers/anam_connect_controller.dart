import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/anam/domain/services/anam_service.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';

class AnamConnectController extends GetxController {
  AnamConnectController({
    required AnamService anamService,
    required ProfileService profileService,
  })  : _anamService = anamService,
        _profileService = profileService;

  final AnamService _anamService;
  final ProfileService _profileService;


  final personaController = TextEditingController();
  final submitState = LoadingState.initial.obs;
  final RxBool hasConfiguredPersona = false.obs;

  String? get configuredPersonaId =>
      _profileService.getCachedTrainerProfile()?.anamAI?.personaId?.trim();

  @override
  void onInit() {
    super.onInit();
    _loadSavedPersonaId();
  }

  void _updateConfiguredPersonaState() {
    final anamAI = _profileService.getCachedTrainerProfile()?.anamAI;
    final personaId = anamAI?.personaId?.trim() ?? '';
    hasConfiguredPersona.value =
        anamAI?.isEnabled == true && personaId.isNotEmpty;
  }

  Future<void> _loadSavedPersonaId() async {
    var personaId = _profileService.getCachedTrainerProfile()?.anamAI?.personaId;
    if (personaId == null || personaId.isEmpty) {
      try {
        await _profileService.fetchTrainerProfile();
        personaId = _profileService.getCachedTrainerProfile()?.anamAI?.personaId;
      } catch (_) {}
    }

    _updateConfiguredPersonaState();

    if (!hasConfiguredPersona.value &&
        personaId != null &&
        personaId.isNotEmpty) {
      personaController.text = personaId;
    }
  }

  @override
  void onClose() {
    personaController.dispose();
    super.onClose();
  }

  Future<String?> _resolveTrainerId() async {
    final cachedId = _profileService.getCachedTrainerProfile()?.sId;
    if (cachedId != null && cachedId.isNotEmpty) return cachedId;

    await _profileService.fetchTrainerProfile();
    return _profileService.getCachedTrainerProfile()?.sId;
  }

  Future<void> connectPersona() async {
    final personaId = personaController.text.trim();
    if (personaId.isEmpty) {
      ToastMessageHelper.show('Enter your Anam persona ID');
      return;
    }

    try {
      submitState.value = LoadingState.loading;

      final trainerId = await _resolveTrainerId();
      if (trainerId == null || trainerId.isEmpty) {
        throw Exception('Trainer ID not found');
      }

      await _anamService.saveTrainerPersona(
        trainerId: trainerId,
        personaId: personaId,
      );

      await _profileService.fetchTrainerProfile();
      _updateConfiguredPersonaState();
      if (Get.isRegistered<ProfileController>()) {
        await ProfileController.to.loadData();
      }

      submitState.value = LoadingState.loaded;
      ToastMessageHelper.show('Persona ID saved');
      Get.back();
    } catch (e) {
      submitState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
    }
  }
}
