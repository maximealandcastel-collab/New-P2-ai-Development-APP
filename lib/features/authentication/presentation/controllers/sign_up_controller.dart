import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';

class SignUpController extends GetxController {
  final AuthService _authService;

  static SignUpController get to => Get.find();

  SignUpController({required AuthService authService})
    : _authService = authService;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final genderController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
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
  String? _tenantId;
  String? gymName;
  Map<String, dynamic>? _memberDraft;
  Map<String, dynamic>? _registeredMemberDraft;

  Map<String, dynamic>? takeMemberDraft() {
    final draft = _registeredMemberDraft;
    _registeredMemberDraft = null;
    return draft;
  }
  static String formatGenderForBackend(String rawGender) {
    final g = rawGender.trim().toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    if (g == 'male') return 'male';
    if (g == 'female') return 'female';
    return 'not_prefer_to_say';
  }

  bool get hasPartnerGym => _tenantId != null;

  bool get canShowRegistrationForm => _customerGatePassed || _trainerEntry;

  void configureEntry(dynamic arguments) {
    debugPrint('🔵 [SignUpController.configureEntry] Arguments: $arguments');
    final draft = arguments is Map ? arguments['memberDraft'] : null;
    _memberDraft = draft is Map ? Map<String, dynamic>.from(draft) : null;
    if (_memberDraft != null) {
      firstNameController.text = _memberDraft!['firstName'] as String? ?? '';
      lastNameController.text = _memberDraft!['lastName'] as String? ?? '';
      emailController.text = _memberDraft!['email'] as String? ?? '';
      genderController.text = _memberDraft!['gender'] as String? ?? '';
    }
    _tenantId = arguments is Map ? arguments['tenantId']?.toString() : null;
    gymName = arguments is Map ? arguments['gymName']?.toString() : null;
    if (arguments is Map && arguments['trainerEntry'] == true) {
      _trainerEntry = true;
      _customerGatePassed = false;
      _selectedRole.value = 'Trainer';
      debugPrint('   Configured as Trainer: _trainerEntry=true, _customerGatePassed=false');
      return;
    }
    if (arguments is Map && arguments['paywallPassed'] == true) {
      _customerGatePassed = true;
      _trainerEntry = false;
      _selectedRole.value = 'User';
      debugPrint('   Configured as User (paywallPassed): _customerGatePassed=true, _trainerEntry=false');
      return;
    }
    _customerGatePassed = false;
    _trainerEntry = false;
    _selectedRole.value = 'User';
    debugPrint('   Default configured as User: _customerGatePassed=false, _trainerEntry=false');
  }

  void openCustomerPaywall() {
    debugPrint('🔵 [SignUpController.openCustomerPaywall] Redirecting to paywall screen...');
    Get.offNamed(
      AppRoute.paywallScreen,
      arguments: {
        'preSignup': true,
        'nextRoute': AppRoute.signUpScreen,
        'freeRoute': AppRoute.signUpScreen,
        'nextArguments': {
          'paywallPassed': true,
          'role': 'User',
          if (_tenantId != null) 'tenantId': _tenantId,
          if (gymName != null) 'gymName': gymName,
          if (_memberDraft != null) 'memberDraft': _memberDraft,
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
    debugPrint('🔵 [SignUpController.changeRole] Requested role: "$role" (customerGatePassed: $_customerGatePassed, trainerEntry: $_trainerEntry)');
    if (role.toLowerCase() == 'user' && !_customerGatePassed) {
      debugPrint('   User role requested without passing customer gate. Opening paywall...');
      openCustomerPaywall();
      return;
    }
    if (role.toLowerCase() == 'trainer') {
      _trainerEntry = true;
    }
    _selectedRole.value = role;
    debugPrint('   Updated selectedRole: $role, _trainerEntry: $_trainerEntry, _customerGatePassed: $_customerGatePassed');
  }

  Future<bool> register({bool navigateOnSuccess = true, GlobalKey<FormState>? formKey}) async {
    debugPrint('🔵 [SignUpController.register] Attempting registration...');
    debugPrint('   canShowRegistrationForm: $canShowRegistrationForm (customerGatePassed: $_customerGatePassed, trainerEntry: $_trainerEntry)');
    debugPrint('   selectedRole: ${_selectedRole.value}');
    debugPrint('   tenantId: $_tenantId');
    debugPrint('   gymName: $gymName');
    debugPrint('   acceptedTerms: ${acceptedTerms.value}');
    debugPrint('   email: "${emailController.text.trim()}"');

    if (!canShowRegistrationForm) {
      debugPrint('❌ [SignUpController.register] Blocked: canShowRegistrationForm is false -> opening customer paywall');
      openCustomerPaywall();
      return false;
    }
    if (_registerState.value == LoadingState.loading) {
      debugPrint('⚠️ [SignUpController.register] Blocked: already in loading state');
      return false;
    }

    final targetForm = formKey ?? registerFormKey;
    final formState = targetForm.currentState;
    debugPrint('   formState exists: ${formState != null} (targetForm: $targetForm)');

    if (formState != null) {
      final formValid = formState.validate();
      debugPrint('   formValid: $formValid (targetForm: $targetForm)');
      if (!formValid) {
        debugPrint('❌ [SignUpController.register] Blocked: Form validation failed on $targetForm.');
        debugPrint('   Current field snapshot:');
        debugPrint('   - First Name: "${firstNameController.text}"');
        debugPrint('   - Last Name: "${lastNameController.text}"');
        debugPrint('   - Gender: "${genderController.text}"');
        debugPrint('   - Phone: "${phoneController.text}"');
        debugPrint('   - Email: "${emailController.text}"');
        debugPrint('   - Password length: ${passwordController.text.length}');
        debugPrint('   - Confirm Password: "${confirmPasswordController.text}"');
        return false;
      }
    } else {
      debugPrint('ℹ️ [SignUpController.register] FormState is null for $targetForm (e.g. multi-step wizard). Performing direct field checks...');
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.isNotEmpty
          ? passwordController.text
          : confirmPasswordController.text;

      if (firstName.isEmpty) {
        debugPrint('❌ [SignUpController.register] Direct validation failed: First name is required.');
        ToastMessageHelper.show('Please enter your first name.');
        return false;
      }
      if (lastName.isEmpty) {
        debugPrint('❌ [SignUpController.register] Direct validation failed: Last name is required.');
        ToastMessageHelper.show('Please enter your last name.');
        return false;
      }
      if (email.isEmpty || !email.contains('@')) {
        debugPrint('❌ [SignUpController.register] Direct validation failed: Valid email required ("$email").');
        ToastMessageHelper.show('Please enter a valid email address.');
        return false;
      }
      final rawGender = genderController.text.trim();
      if (rawGender.isEmpty) {
        debugPrint('❌ [SignUpController.register] Direct validation failed: Gender is required.');
        ToastMessageHelper.show('Please select your gender.');
        return false;
      }
      if (password.length < 8) {
        debugPrint('❌ [SignUpController.register] Direct validation failed: Password must be at least 8 chars.');
        ToastMessageHelper.show('Password must be at least 8 characters.');
        return false;
      }
    }

    final rawGender = genderController.text.trim();
    if (rawGender.isEmpty) {
      debugPrint('❌ [SignUpController.register] Blocked: Gender is required');
      ToastMessageHelper.show('Please select your gender.');
      return false;
    }

    if (!acceptedTerms.value) {
      debugPrint('❌ [SignUpController.register] Blocked: Terms of service not accepted');
      ToastMessageHelper.show('Please accept the Terms of Service and Privacy Policy.');
      return false;
    }

    _registerState.value = LoadingState.loading;
    try {
      final referral = referralCodeController.text.trim();
      final sanitizedGender = formatGenderForBackend(rawGender);
      final sanitizedRole = _selectedRole.value.toLowerCase();
      final resolvedTenantId = _selectedRole.value == 'User' ? _tenantId : null;
      final passwordToSend = confirmPasswordController.text.isNotEmpty
          ? confirmPasswordController.text
          : passwordController.text;

      debugPrint('🚀 [SignUpController.register] Calling _authService.register with:');
      debugPrint('   firstName: "${firstNameController.text.trim()}"');
      debugPrint('   lastName: "${lastNameController.text.trim()}"');
      debugPrint('   email: "${emailController.text.trim()}"');
      debugPrint('   rawGender: "$rawGender" -> sanitizedGender: "$sanitizedGender"');
      debugPrint('   role: "$sanitizedRole"');
      debugPrint('   phone: "${phoneController.text.trim()}"');
      debugPrint('   dob: "${dobController.text.trim()}"');
      debugPrint('   referredByCode: "${referral.isNotEmpty ? referral : null}"');
      debugPrint('   tenantId: "$resolvedTenantId"');

      final token = await _authService.register(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        gender: sanitizedGender,
        role: sanitizedRole,
        password: passwordToSend,
        phone: phoneController.text.trim(),
        dob: dobController.text.trim(),
        referredByCode: referral.isNotEmpty ? referral : null,
        tenantId: resolvedTenantId,
      );

      debugPrint('🟢 [SignUpController.register] Registration succeeded! Received token length: ${token.length}');

      _registeredMemberDraft = _selectedRole.value == 'User' && _memberDraft != null
          ? {..._memberDraft!, 'firstName': firstNameController.text.trim(),
              'lastName': lastNameController.text.trim(), 'email': emailController.text.trim(),
              'gender': genderController.text.trim(), 'phone': phoneController.text.trim(), 'dob': dobController.text.trim()}
          : null;
      // Persist the referral code so the paywall can auto-apply 50% off
      if (referral.isNotEmpty) {
        debugPrint('   Persisting referral promo code: $referral');
        await CacheService().put('pendingPromoCode', referral.toUpperCase());
      }
      _registerState.value = LoadingState.loaded;
      if (navigateOnSuccess) {
        debugPrint('📲 [SignUpController.register] Navigating to OTP verification screen');
        Get.toNamed(
          AppRoute.otpVerificationScreen,
          arguments: 'signup',
        );
      }
      return true;
    } catch (e, stackTrace) {
      debugPrint('🔴 [SignUpController.register] Exception caught during registration:');
      debugPrint('   Error: $e');
      debugPrint('   Error Message: ${e.errorMessage}');
      debugPrint('   StackTrace:\n$stackTrace');
      ToastMessageHelper.show(e.errorMessage);
      _registerState.value = LoadingState.error;
      return false;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    phoneController.dispose();
    dobController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referralCodeController.dispose();
    super.dispose();
  }
}
