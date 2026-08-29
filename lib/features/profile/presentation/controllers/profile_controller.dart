import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/features/profile/data/models/user_model.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';

class ProfileController extends GetxController {
  ProfileController({
    required ProfileService service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  final ProfileService _service;
  final ConnectivityService _connectivityService;

  static ProfileController get to => Get.find();

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _updateLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;
  LoadingState get updateLoadingState => _updateLoadingState.value;

  final _userData = Rxn<UserModel>();
  UserModel? get userData => _userData.value;

  final _trainerData = Rxn<TrainerDetailsModel>();
  TrainerDetailsModel? get trainerData => _trainerData.value;

  final _selectedProfilePicture = Rxn<File>();
  final _selectedCoverPhoto = Rxn<File>();

  File? get selectedProfilePicture => _selectedProfilePicture.value;
  File? get selectedCoverPhoto => _selectedCoverPhoto.value;

  final personalFormKey = GlobalKey<FormState>();
  final fitnessFormKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final genderController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  final primaryGoalController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final fitnessLevelController = TextEditingController();
  final equipmentController = TextEditingController();
  final trainingDaysController = TextEditingController();
  final motivationStyleController = TextEditingController();

  DateTime selectedDateOfBirth = DateTime(1995, 6, 15);
  List<String> _injuries = [];

  List<String> get injuries => List.unmodifiable(_injuries);

  @override
  void onInit() {
    super.onInit();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) loadData();
    });
    loadData();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    dateOfBirthController.dispose();
    primaryGoalController.dispose();
    heightController.dispose();
    weightController.dispose();
    fitnessLevelController.dispose();
    equipmentController.dispose();
    trainingDaysController.dispose();
    motivationStyleController.dispose();
    super.onClose();
  }

  void initPersonalInfoForm() {
    final user = userData;
    if (user == null) return;

    firstNameController.text = user.firstName ?? '';
    lastNameController.text = user.lastName ?? '';
    genderController.text = MenuShowHelper.genderDisplayValue(user.gender);
    if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
      selectedDateOfBirth = DateTime.parse(user.dateOfBirth!);
      dateOfBirthController.text =
          TimeFormatHelper.formatDate(selectedDateOfBirth);
    } else {
      dateOfBirthController.clear();
    }
  }

  void initFitnessInfoForm() {
    final user = userData;
    if (user == null) return;

    primaryGoalController.text =
        MenuShowHelper.goalDisplayValue(user.primaryGoal) ?? '';
    heightController.text = MenuShowHelper.heightDisplayValue(user.height);
    weightController.text = MenuShowHelper.weightDisplayValue(user.weight);
    fitnessLevelController.text =
        MenuShowHelper.fitnessLevelDisplayValue(user.fitnessLevel);
    equipmentController.text =
        MenuShowHelper.equipmentDisplayValue(user.availableEquipment) ?? '';
    trainingDaysController.text = user.trainingDaysPerWeek?.toString() ?? '';
    motivationStyleController.text =
        MenuShowHelper.motivationStyleDisplayValue(user.motivationStyle) ?? '';
    _injuries = List<String>.from(user.injuries ?? []);
  }

  void setInjuries(List<String> values) {
    _injuries = values.where((e) => e.trim().isNotEmpty).toList();
  }

  Future<void> loadData() async {
    try {
      final cachedUser = _service.getCachedUserData();
      final hasCache = _service.hasCache();
      final hasTrainerCache = _service.hasTrainerCache();
      final isTrainer = cachedUser?.role == 'trainer';
      final isOnline = _connectivityService.isConnected.value;
      final hasRequiredCache = hasCache && (!isTrainer || hasTrainerCache);


      if (hasRequiredCache) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }

      if (!isOnline) return;

      try {
        await _service.fetchUserProfile();
        _loadFromCache();

        if (_userData.value?.role == 'trainer') {
          if (!_service.hasTrainerCache()) {
            _loadingState.value = LoadingState.loading;
          }
          await _service.fetchTrainerProfile();
          _loadFromCache();
        }

        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasRequiredCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch error: $e');
      }
    } catch (e) {
      if (_service.hasCache() &&
          (_service.getCachedUserData()?.role != 'trainer' ||
              _service.hasTrainerCache())) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected error: $e');
    }
  }

  void _loadFromCache() {
    _userData.value = _service.getCachedUserData();
    _trainerData.value = _service.getCachedTrainerProfile();
  }

  @override
  Future<void> refresh() => loadData();

  Future<void> uploadProfilePicture(File file) async {
    _selectedProfilePicture.value = file;
    _updateLoadingState.value = LoadingState.loading;
    try {
      _userData.value = await _service.uploadProfilePicture(file);
      _selectedProfilePicture.value = null;
      _updateLoadingState.value = LoadingState.loaded;
    } on AppException catch (e) {
      _selectedProfilePicture.value = null;
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
    } catch (e) {
      _selectedProfilePicture.value = null;
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show('Failed to upload profile picture');
      if (kDebugMode) debugPrint('Upload profile picture error: $e');
    }
  }

  Future<void> uploadCoverPhoto(File file) async {
    _selectedCoverPhoto.value = file;
    _updateLoadingState.value = LoadingState.loading;
    try {
      _userData.value = await _service.uploadCoverPhoto(file);
      _selectedCoverPhoto.value = null;
      _updateLoadingState.value = LoadingState.loaded;
    } on AppException catch (e) {
      _selectedCoverPhoto.value = null;
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
    } catch (e) {
      _selectedCoverPhoto.value = null;
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show('Failed to upload cover photo');
      if (kDebugMode) debugPrint('Upload cover photo error: $e');
    }
  }

  Map<String, dynamic> personalInfoUpdates() => {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'gender': MenuShowHelper.genderBackendValue(genderController.text.trim()),
        'dateOfBirth': TimeFormatHelper.formatDateWithHifen(selectedDateOfBirth),
      };

  Map<String, dynamic> fitnessInfoUpdates() {
    final trainingDays = int.tryParse(trainingDaysController.text.trim());

    return {
      'primaryGoal': MenuShowHelper.goalBackendValue(
            primaryGoalController.text.trim(),
          ) ??
          primaryGoalController.text.trim(),
      'height': StringFormat.parseHeight(heightController.text),
      'weight': StringFormat.parseWeight(weightController.text),
      'fitnessLevel': MenuShowHelper.fitnessLevelBackendValue(
        fitnessLevelController.text.trim(),
      ),
      'availableEquipment': equipmentController.text.trim(),
      'trainingDaysPerWeek': ?trainingDays,
      'injuries': _injuries,
      'motivationStyle': motivationStyleController.text.trim(),
    };
  }

  Future<void> updateProfile({
    required Map<String, dynamic> updates,
    GlobalKey<FormState>? formKey,
    bool popOnSuccess = true,
  }) async {
    if (formKey != null && !(formKey.currentState?.validate() ?? false)) {
      return;
    }

    _updateLoadingState.value = LoadingState.loading;
    try {
      _userData.value = await _service.updateUserProfile(updates);
      _updateLoadingState.value = LoadingState.loaded;
      if (popOnSuccess) Get.back();
    } on AppException catch (e) {
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
    } catch (e) {
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show('Failed to update profile');
      if (kDebugMode) debugPrint('Update profile error: $e');
    }
  }



}
