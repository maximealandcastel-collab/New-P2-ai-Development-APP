import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/features/profile/data/models/user_model.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';

class EditPersonalInfoController extends GetxController {
  static EditPersonalInfoController get to => Get.find();

  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final genderController = TextEditingController();
  final preferredNameController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  DateTime selectedDateOfBirth = DateTime(1995, 6, 15);

  final _saveState = LoadingState.initial.obs;
  LoadingState get saveState => _saveState.value;

  @override
  void onInit() {
    super.onInit();
    _populateFromUser(ProfileController.to.userData);
  }

  void _populateFromUser(UserModel? user) {
    if (user == null) return;

    firstNameController.text = user.firstName ?? '';
    lastNameController.text = user.lastName ?? '';
    genderController.text = MenuShowHelper.genderDisplayValue(user.gender);
    preferredNameController.text = user.preferredName ?? '';

    if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
      selectedDateOfBirth = DateTime.parse(user.dateOfBirth!);
      dateOfBirthController.text =
          TimeFormatHelper.formatDate(selectedDateOfBirth);
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    _saveState.value = LoadingState.loading;

    final data = <String, dynamic>{
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'gender': MenuShowHelper.genderBackendValue(genderController.text.trim()),
      'preferredName': preferredNameController.text.trim(),
      'dateOfBirth': TimeFormatHelper.formatDateWithHifen(selectedDateOfBirth),
    };

    final success = await ProfileController.to.updateProfileInformation(data);
    _saveState.value = success ? LoadingState.loaded : LoadingState.error;

    if (success) Get.back();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    preferredNameController.dispose();
    dateOfBirthController.dispose();
    super.onClose();
  }
}
