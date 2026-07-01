import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/anam/domain/services/anam_service.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';

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

      submitState.value = LoadingState.loaded;
      ToastMessageHelper.show('AI video chat connected');
      Get.back();
    } catch (e) {
      submitState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
    }
  }
}
