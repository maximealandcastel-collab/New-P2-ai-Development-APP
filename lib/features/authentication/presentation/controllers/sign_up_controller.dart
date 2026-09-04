import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/admin_bypass_screen.dart';

class SignUpController extends GetxController {
  final AuthService _authService;

  static SignUpController get to => Get.find();

  SignUpController({required AuthService authService})
    : _authService = authService;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final genderController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController(
    text: kDebugMode
        ? const String.fromEnvironment(
            'PREFILL_SIGNUP_EMAIL',
            defaultValue: '',
          )
        : '',
  );
  final passwordController = TextEditingController(
    text: kDebugMode
        ? const String.fromEnvironment(
            'PREFILL_SIGNUP_PASSWORD',
            defaultValue: '',
          )
        : '',
  );
  final confirmPasswordController = TextEditingController();
  final referralCodeController = TextEditingController();
  final showReferralField = false.obs;
  final acceptedTerms = false.obs;

  bool _customerGatePassed = false;
  bool _trainerEntry = false;

  bool get canShowRegistrationForm => _customerGatePassed || _trainerEntry;

  void configureEntry(dynamic arguments) {
    if (arguments is Map && arguments['trainerEntry'] == true) {
      _trainerEntry = true;
      _customerGatePassed = false;
      _selectedRole.value = 'Trainer';
      return;
    }
    if (arguments is Map && arguments['paywallPassed'] == true) {
      _customerGatePassed = true;
      _trainerEntry = false;
      _selectedRole.value = 'User';
      return;
    }
    _customerGatePassed = false;
    _trainerEntry = false;
    _selectedRole.value = 'User';
  }

  void openCustomerPaywall() {
    Get.offNamed(
      AppRoute.paywallScreen,
      arguments: {
        'preSignup': true,
        'nextRoute': AppRoute.signUpScreen,
        'freeRoute': AppRoute.signUpScreen,
        'nextArguments': {
          'paywallPassed': true,
          'role': 'User',
        },
      },
    );
  }

  final registerFormKey = GlobalKey<FormState>();

  final _registerState = LoadingState.initial.obs;

  LoadingState get registerState => _registerState.value;

  final RxString _selectedRole = 'Trainer'.obs;

  String get selectedRole => _selectedRole.value;

  void changeRole(String role) {
    if (role.toLowerCase() == 'user' && !_customerGatePassed) {
      openCustomerPaywall();
      return;
    }
    if (role.toLowerCase() == 'trainer') {
      _trainerEntry = true;
    }
    _selectedRole.value = role;
    debugPrint('Selected role: $role');
  }

  Future<void> register() async {
    if (!canShowRegistrationForm) {
      openCustomerPaywall();
      return;
    }
    if (!registerFormKey.currentState!.validate()) return;
    if (!acceptedTerms.value) {
      ToastMessageHelper.show('Please accept the Terms of Service and Privacy Policy.');
      return;
    }

    _registerState.value = LoadingState.loading;
    try {
      final referral = referralCodeController.text.trim();
      await _authService.register(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        gender: genderController.text.trim().toLowerCase(),
        role: _selectedRole.value.toLowerCase(),
        password: confirmPasswordController.text,
        referredByCode: referral.isNotEmpty ? referral : null,
      );
      // Persist the referral code so the paywall can auto-apply 50% off
      if (referral.isNotEmpty) {
        await CacheService().put('pendingPromoCode', referral.toUpperCase());
      }
      _registerState.value = LoadingState.loaded;
      Get.toNamed(
        AppRoute.otpVerificationScreen,
        arguments: 'signup',
      );
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _registerState.value = LoadingState.error;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referralCodeController.dispose();
    super.dispose();
  }
}
