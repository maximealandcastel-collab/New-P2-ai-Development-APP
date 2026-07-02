import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/user/workout/domain/services/workout_service.dart';

class WorkoutGeneratingController extends GetxController {
  WorkoutGeneratingController({required WorkoutService service}) : _service = service;

  final WorkoutService _service;

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _generateWorkout();
  }

  Future<void> _generateWorkout() async {
    final arguments = Get.arguments;
    if (arguments is! Map<String, dynamic>) {
      _handleFailure('Invalid workout data');
      return;
    }

    try {
      isLoading.value = true;
      final workout = await _service.createAndGenerateWorkout(arguments);
      Get.offNamed(AppRoute.workoutPlanDetailsScreen, arguments: workout);
    } catch (e) {
      _handleFailure(e.errorMessage);
      if (kDebugMode) debugPrint('generateWorkout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleFailure(String message) {
    ToastMessageHelper.show(message);
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    }
  }
}
