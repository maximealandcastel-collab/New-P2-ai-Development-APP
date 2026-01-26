import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/utils/validators/app_validator.dart';

class SignUpController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final conPasswordController = TextEditingController();
  final facilityNameController = TextEditingController();
  final facilityAccountNumberController = TextEditingController();

  final selectedFacilityType = "".obs;
  final facilityList = ["Gym Facility", "Others Facility"].obs;
  void changeFacilityType(value) {
    selectedFacilityType.value = value;
  }

  final selectedTab = "Trainer".obs;
  void changeTab(value) {
    selectedTab.value = value;
    log("selected tab is : ${selectedTab.value}");
  }

  final passwordNotVisible = true.obs;
  void changeVisibility() {
    passwordNotVisible.value = !passwordNotVisible.value;
  }

  final passwordNotVisible2 = true.obs;
  void changeVisibility2() {
    passwordNotVisible2.value = !passwordNotVisible2.value;
  }

  final filePath = "".obs;

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        debugPrint("File name: ${file.name}");
        debugPrint("File path: ${file.path}");
        debugPrint("File size: ${file.size}");

        filePath.value = file.path ?? "";
        validateFieldFacility();
      } else {
        debugPrint("User cancelled file picking");
      }
    } catch (e) {
      debugPrint("File pick error: $e");
    }
  }

  final isValidate = false.obs;
  void validateField() {
    if (AppValidator.validateEmail(emailController.text) == null &&
        AppValidator.validatePassword(passwordController.text) == null &&
        AppValidator.validateConfirmPassword(
              conPasswordController.text,
              passwordController.text,
            ) ==
            null) {
      isValidate.value = true;
    } else {
      isValidate.value = false;
    }
  }

  final isValidateFacility = false.obs;
  void validateFieldFacility() {
    if (facilityAccountNumberController.text.isNotEmpty &&
        selectedFacilityType.value.isNotEmpty &&
        facilityAccountNumberController.text.isNotEmpty &&
        filePath.value.isNotEmpty) {
      isValidateFacility.value = true;
    } else {
      isValidateFacility.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    validateField();
    validateFieldFacility();
  }

  @override
  void onClose() {
    emailController.clear();
    passwordController.clear();
    conPasswordController.clear();
    facilityNameController.clear();
    facilityAccountNumberController.clear();
    super.onClose();
  }
}
