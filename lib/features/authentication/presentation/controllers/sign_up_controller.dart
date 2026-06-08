import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
class SignUpController extends GetxController {
  final AuthService _authService;

  static SignUpController get to => Get.find();

  SignUpController({required AuthService authService})
      : _authService = authService;



  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final genderController = TextEditingController();
  final emailController = TextEditingController(text: kDebugMode ? 'dev.milon923@gmail.com' : '');
  final passwordController = TextEditingController(text: kDebugMode ? '1qazxsw2' : '');
  final confirmPasswordController = TextEditingController();

  final registerFormKey = GlobalKey<FormState>();

  final _registerState = LoadingState.initial.obs;
  LoadingState get registerState => _registerState.value;


  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    _registerState.value = LoadingState.loading;
    try {
      await _authService.register(
        name: firstNameController.text.trim(),
        email: emailController.text.trim(),
        gender: genderController.text.trim(),
        confirmPassword: confirmPasswordController.text,
      );
      _registerState.value = LoadingState.loaded;
    } catch (e) {
      _registerState.value = LoadingState.error;
    }
  }

}
