import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/trainer_profile_model.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/user_profile_model.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';

class ProfileCompleteController extends GetxController {
  final AuthService _authService;
  final ProfileService _profileService;

  static ProfileCompleteController get to => Get.find();

  ProfileCompleteController({
    required AuthService authService,
    required ProfileService profileService,
  }) : _authService = authService,
       _profileService = profileService;

  // ─── State ───────────────────────────────

  final _trainerState = LoadingState.initial.obs;
  final _userState = LoadingState.initial.obs;

  LoadingState get trainerState => _trainerState.value;

  LoadingState get userState => _userState.value;

  // ─── Trainer fields ───────────────────────
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final specialityController = TextEditingController();
  final premiumPriceController = TextEditingController();
  List<String> _certifications = [];
  List<String> _trainingStyleTags = [];

  // ─── User fields ───────────────────────
  final primaryGoalController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final fitnessLevelController = TextEditingController();
  final equipmentController = TextEditingController();
  final trainingDaysController = TextEditingController();
  final preferredNameController = TextEditingController();
  final motivationStyleController = TextEditingController();
  List<String> _injuries = [];
  DateTime selectedDateOfBirth = DateTime(1995, 6, 15);

  void setCertifications(List<String> values) =>
      _certifications = values.where((e) => e.trim().isNotEmpty).toList();

  void setTrainingStyleTags(List<String> values) => _trainingStyleTags = values;

  void setInjuries(List<String> values) =>
      _injuries = values.where((e) => e.trim().isNotEmpty).toList();

  bool validateTrainerStep(int step) {
    switch (step) {
      case 1:
        if (_certifications.isEmpty) {
          ToastMessageHelper.show('Please add at least one certification');
          return false;
        }
        return true;
      case 3:
        if (_trainingStyleTags.isEmpty) {
          ToastMessageHelper.show('Please add at least one trainer tag');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  bool isTrainerTextStepValid(int step) {
    switch (step) {
      case 0:
        return usernameController.text.trim().isNotEmpty &&
            bioController.text.trim().isNotEmpty;
      case 2:
        return specialityController.text.trim().isNotEmpty;
      case 4:
        final premiumPrice = int.tryParse(premiumPriceController.text.trim());
        return premiumPrice != null && premiumPrice > 0;
      default:
        return true;
    }
  }

  bool isUserTextStepValid(int step) {
    switch (step) {
      case 0:
        return primaryGoalController.text.trim().isNotEmpty &&
            dateOfBirthController.text.trim().isNotEmpty;
      case 1:
        return heightController.text.trim().isNotEmpty &&
            weightController.text.trim().isNotEmpty &&
            fitnessLevelController.text.trim().isNotEmpty;
      case 2:
        final days = int.tryParse(trainingDaysController.text.trim());
        return equipmentController.text.trim().isNotEmpty &&
            days != null &&
            days > 0 &&
            days <= 7;
      case 3:
        return preferredNameController.text.trim().isNotEmpty &&
            motivationStyleController.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  final trainerFormKey = GlobalKey<FormState>();
  final userFormKey = GlobalKey<FormState>();

  Future<void> registerTrainer() async {
    try {
      _trainerState.value = LoadingState.loading;
      await _authService.registerTrainer(
        TrainerProfileModel(
          name: usernameController.text.trim(),
          bio: bioController.text.trim(),
          certifications: _certifications,
          specialty: MenuShowHelper.specialityBackendValue(
                specialityController.text.trim(),
              ) ??
              specialityController.text.trim(),
          trainingStyleTags: _trainingStyleTags,
          subscriptionPrice: SubscriptionPrice(
            premium: int.parse(premiumPriceController.text.trim()),
          ),
        ),
      );
      _trainerState.value = LoadingState.loaded;
      Get.offAllNamed(AppRoute.aiInstructionScreen);
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _trainerState.value = LoadingState.error;
    }
  }

  Future<String?> _resolveGender() async {
    final cachedProfileGender = _profileService.getCachedUserData()?.gender;
    if (cachedProfileGender != null && cachedProfileGender.isNotEmpty) {
      return MenuShowHelper.genderBackendValue(cachedProfileGender);
    }

    final cachedGender = _authService.getGender();
    if (cachedGender != null && cachedGender.isNotEmpty) return cachedGender;

    try {
      await _profileService.fetchUserProfile();
      final fetchedGender = _profileService.getCachedUserData()?.gender;
      if (fetchedGender != null && fetchedGender.isNotEmpty) {
        return MenuShowHelper.genderBackendValue(fetchedGender);
      }
    } catch (_) {}

    return null;
  }

  Future<void> registerUser() async {
    _userState.value = LoadingState.loading;

    try {
      final gender = await _resolveGender();
      if (gender == null || gender.isEmpty) {
        ToastMessageHelper.show('Gender not found. Please sign up again.');
        _userState.value = LoadingState.error;
        return;
      }

      await _authService.registerUser(
        UserProfileModel(
          primaryGoal: MenuShowHelper.goalBackendValue(
                primaryGoalController.text.trim(),
              ) ??
              primaryGoalController.text.trim(),
          gender: gender,
          dateOfBirth: selectedDateOfBirth.toIso8601String().split('T').first,
          height: StringFormat.parseHeight(heightController.text),
          weight: StringFormat.parseWeight(heightController.text)?.round(),
          fitnessLevel: MenuShowHelper.fitnessLevelBackendValue(
            fitnessLevelController.text.trim(),
          ),
          availableEquipment: MenuShowHelper.equipmentBackendValue(
                equipmentController.text.trim(),
              ) ??
              equipmentController.text.trim(),
          trainingDaysPerWeek: int.tryParse(trainingDaysController.text.trim()),
          injuries: _injuries,
          preferredName: preferredNameController.text.trim(),
          motivationStyle: MenuShowHelper.motivationStyleBackendValue(
                motivationStyleController.text.trim(),
              ) ??
              motivationStyleController.text.trim(),
        ),
      );
      _userState.value = LoadingState.loaded;
      Get.offAllNamed(AppRoute.paywallScreen);
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _userState.value = LoadingState.error;
    }
  }

  bool isTrainer() {
    final role = _authService.getRole();
    if (role != null) {
      return role == 'trainer';
    }
    return false;
  }

  @override
  void onClose() {
    usernameController.dispose();
    bioController.dispose();
    specialityController.dispose();
    premiumPriceController.dispose();
    primaryGoalController.dispose();
    dateOfBirthController.dispose();
    heightController.dispose();
    weightController.dispose();
    fitnessLevelController.dispose();
    equipmentController.dispose();
    trainingDaysController.dispose();
    preferredNameController.dispose();
    motivationStyleController.dispose();
    super.onClose();
  }
}
