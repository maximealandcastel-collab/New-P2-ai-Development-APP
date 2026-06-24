import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/features/profile/data/models/user_model.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';

class ProfileInformationController extends GetxController {
  static ProfileInformationController get to => Get.find();

  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  final roleController = TextEditingController();
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

  final _saveState = LoadingState.initial.obs;
  LoadingState get saveState => _saveState.value;

  List<String> get injuries => List.unmodifiable(_injuries);

  @override
  void onInit() {
    super.onInit();
    _populateFromUser(ProfileController.to.userData);
  }

  void setInjuries(List<String> values) {
    _injuries = values.where((e) => e.trim().isNotEmpty).toList();
  }

  void _populateFromUser(UserModel? user) {
    if (user == null) return;

    firstNameController.text = user.firstName ?? '';
    lastNameController.text = user.lastName ?? '';
    emailController.text = user.email ?? '';
    genderController.text = MenuShowHelper.genderDisplayValue(user.gender);
    roleController.text = MenuShowHelper.roleDisplayValue(user.role);
    primaryGoalController.text =
        MenuShowHelper.goalDisplayValue(user.primaryGoal) ?? '';
    heightController.text = MenuShowHelper.heightDisplayValue(user.height);
    weightController.text = MenuShowHelper.weightDisplayValue(user.weight);
    fitnessLevelController.text =
        MenuShowHelper.fitnessLevelDisplayValue(user.fitnessLevel);
    equipmentController.text =
        MenuShowHelper.equipmentDisplayValue(user.availableEquipment) ?? '';
    trainingDaysController.text =
        user.trainingDaysPerWeek?.toString() ?? '';
    preferredNameController.text = user.preferredName ?? '';
    motivationStyleController.text =
        MenuShowHelper.motivationStyleDisplayValue(user.motivationStyle) ?? '';
    _injuries = List<String>.from(user.injuries ?? []);

    if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
      selectedDateOfBirth = DateTime.parse(user.dateOfBirth!);
      dateOfBirthController.text =
          TimeFormatHelper.formatDate(selectedDateOfBirth);
    }
  }

  int? _parseHeight(String value) {
    final cmMatch = RegExp(r'\((\d+)\s*cm\)').firstMatch(value.trim());
    if (cmMatch != null) {
      return int.tryParse(cmMatch.group(1)!);
    }
    return int.tryParse(value.trim());
  }

  int? _parseWeight(String value) {
    final match = RegExp(r'(\d+)').firstMatch(value.trim());
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    final trainingDays = int.tryParse(trainingDaysController.text.trim());
    if (trainingDays == null || trainingDays <= 0 || trainingDays > 7) {
      return;
    }

    _saveState.value = LoadingState.loading;

    final data = <String, dynamic>{
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'gender': MenuShowHelper.genderBackendValue(genderController.text.trim()),
      'primaryGoal': MenuShowHelper.goalBackendValue(
            primaryGoalController.text.trim(),
          ) ??
          primaryGoalController.text.trim(),
      'dateOfBirth': TimeFormatHelper.formatDateWithHifen(selectedDateOfBirth),
      'height': _parseHeight(heightController.text),
      'weight': _parseWeight(weightController.text),
      'fitnessLevel': MenuShowHelper.fitnessLevelBackendValue(
        fitnessLevelController.text.trim(),
      ),
      'availableEquipment': MenuShowHelper.equipmentBackendValue(
            equipmentController.text.trim(),
          ) ??
          equipmentController.text.trim(),
      'trainingDaysPerWeek': trainingDays,
      'injuries': _injuries,
      'preferredName': preferredNameController.text.trim(),
      'motivationStyle': MenuShowHelper.motivationStyleBackendValue(
            motivationStyleController.text.trim(),
          ) ??
          motivationStyleController.text.trim(),
    };

    final success =
        await ProfileController.to.updateProfileInformation(data);
    _saveState.value = success ? LoadingState.loaded : LoadingState.error;

    if (success) {
      Get.back();
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    genderController.dispose();
    roleController.dispose();
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
