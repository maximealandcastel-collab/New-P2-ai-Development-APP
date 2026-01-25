import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/core/utils/validators/app_validator.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final selectedTab = "Trainer".obs;
  void changeTab(value) {
    selectedTab.value = value;
    log("selected tab is : ${selectedTab.value}");
  }

  final passwordNotVisible = true.obs;
  void changeVisibility() {
    passwordNotVisible.value = !passwordNotVisible.value;
  }

  final isValidate = false.obs;
  void validateField() {
    if (AppValidator.validateEmail(emailController.text) == null &&
        AppValidator.validatePassword(passwordController.text) == null) {
      isValidate.value = true;
    } else {
      isValidate.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    validateField();
  }

  @override
  void onClose() {
    emailController.clear();
    passwordController.clear();
    super.onClose();
  }
}
