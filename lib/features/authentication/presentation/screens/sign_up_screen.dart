import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final SignUpController controller;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    controller = SignUpController.to;
    controller.configureEntry(Get.arguments);
    if (!controller.canShowRegistrationForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) controller.openCustomerPaywall();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.canShowRegistrationForm) {
      return const Scaffold(
        backgroundColor: Color(0xFFFCFCFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        child: Form(
          key: controller.registerFormKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 24.h),
                Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 25.sp,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF171717),
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'Join trainers and members building healthier lives together.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF707070),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildRoleToggle(),
                SizedBox(height: 20.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _field(
                        label: 'First Name',
                        hint: 'First name',
                        controller: controller.firstNameController,
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _field(
                        label: 'Last Name',
                        hint: 'Last name',
                        controller: controller.lastNameController,
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                _genderField(),
                SizedBox(height: 14.h),
                _field(
                  label: 'Phone Number',
                  hint: 'e.g. +1 (212) 555-1234',
                  controller: controller.phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 14.h),
                _field(
                  label: 'Email',
                  hint: 'Enter your email address',
                  controller: controller.emailController,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Please enter your email address';
                    if (!email.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                SizedBox(height: 14.h),
                _field(
                  label: 'Password',
                  hint: 'Create a password',
                  controller: controller.passwordController,
                  icon: Icons.lock_outline,
                  obscureText: obscurePassword,
                  onChanged: (_) => setState(() {}),
                  suffix: IconButton(
                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 19.sp,
                      color: const Color(0xFF777777),
                    ),
                  ),
                  validator: _passwordValidator,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 14.h),
                _field(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: controller.confirmPasswordController,
                  icon: Icons.lock_outline,
                  obscureText: obscureConfirmPassword,
                  suffix: IconButton(
                    onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                    icon: Icon(
                      obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 19.sp,
                      color: const Color(0xFF777777),
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').isEmpty) return 'Please confirm your password';
                    if (value != controller.passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 14.h),
                _passwordRequirements(),
                SizedBox(height: 15.h),
                _referralSection(),
                SizedBox(height: 16.h),
                _termsRow(),
                SizedBox(height: 18.h),
                _createAccountButton(),
                SizedBox(height: 20.h),
                Center(
                  child: GestureDetector(
                    onTap: Get.back,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      child: Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF777777)),
                          children: [
                            TextSpan(
                              text: 'Sign in',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: Get.back,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(right: 15.w, top: 8.h, bottom: 8.h),
            child: Icon(Icons.chevron_left, size: 25.sp, color: const Color(0xFF222222)),
          ),
        ),
        Image.asset(
          Assets.images.logo.path,
          width: 42.w,
          height: 42.w,
          fit: BoxFit.contain,
        ),
        SizedBox(width: 10.w),
        Text.rich(
          TextSpan(
            text: 'P2P ',
            children: [
              TextSpan(text: 'FIT TECH AI', style: TextStyle(color: AppColors.primary)),
            ],
          ),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF202020),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleToggle() {
    return Obx(() => Container(
          height: 46.h,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE9E9E9)),
            boxShadow: const [
              BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Expanded(child: _roleOption('Trainer', Icons.fitness_center_outlined)),
              Expanded(child: _roleOption('User', Icons.person_outline)),
            ],
          ),
        ));
  }

  Widget _roleOption(String role, IconData icon) {
    final selected = controller.selectedRole == role;
    return GestureDetector(
      onTap: () => controller.changeRole(role),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFFBF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.sp, color: selected ? AppColors.primary : const Color(0xFF777777)),
              SizedBox(width: 7.w),
              Text(
                role,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF272727),
          ),
        ),
        SizedBox(height: 7.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onChanged: onChanged,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400, color: const Color(0xFF222222)),
          validator: validator ?? (value) => (value ?? '').trim().isEmpty ? 'Required' : null,
          decoration: _inputDecoration(hint, icon, suffix),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, Widget? suffix) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12.5.sp, color: const Color(0xFFAAAAAA), fontWeight: FontWeight.w400),
      prefixIcon: Icon(icon, size: 19.sp, color: const Color(0xFF666666)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 14.h),
      enabledBorder: border(const Color(0xFFE7E7E7)),
      focusedBorder: border(AppColors.primary, 1.2),
      errorBorder: border(const Color(0xFFE26060)),
      focusedErrorBorder: border(const Color(0xFFE26060), 1.2),
      errorStyle: TextStyle(fontSize: 10.5.sp, color: const Color(0xFFB83232), height: 1.15),
    );
  }

  Widget _genderField() {
    final values = HelperData.genderOptions.map((value) => value.toString()).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF272727))),
        SizedBox(height: 7.h),
        DropdownButtonFormField<String>(
          value: controller.genderController.text.isEmpty ? null : controller.genderController.text,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 19.sp, color: const Color(0xFF777777)),
          decoration: _inputDecoration('Select gender', Icons.male_outlined, null),
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF222222)),
          items: values.map((value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
          onChanged: (value) => controller.genderController.text = value ?? '',
          validator: (value) => (value ?? '').isEmpty ? 'Please select gender' : null,
        ),
      ],
    );
  }

  String? _passwordValidator(String? value) {
    final password = value ?? '';
    if (password.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Add one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Add one number';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) return 'Add one special character';
    return null;
  }

  Widget _passwordRequirements() {
    final value = controller.passwordController.text;
    final checks = <MapEntry<String, bool>>[
      MapEntry('At least 8 characters', value.length >= 8),
      MapEntry('One uppercase letter', RegExp(r'[A-Z]').hasMatch(value)),
      MapEntry('One number', RegExp(r'[0-9]').hasMatch(value)),
      MapEntry('One special character', RegExp(r'[^A-Za-z0-9]').hasMatch(value)),
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Password must contain:', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF333333))),
          SizedBox(height: 8.h),
          ...checks.map((check) => Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Row(
                  children: [
                    Icon(
                      check.value ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 13.sp,
                      color: check.value ? AppColors.primary : const Color(0xFFB7B7B7),
                    ),
                    SizedBox(width: 7.w),
                    Text(check.key, style: TextStyle(fontSize: 10.5.sp, color: const Color(0xFF666666))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _referralSection() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => controller.showReferralField.toggle(),
              child: Row(
                children: [
                  Icon(
                    controller.showReferralField.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Have a referral or P2P code?',
                    style: TextStyle(fontSize: 11.5.sp, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (controller.showReferralField.value) ...[
              SizedBox(height: 10.h),
              _field(
                label: 'Referral Code',
                hint: 'Enter code',
                controller: controller.referralCodeController,
                icon: Icons.card_giftcard_outlined,
                validator: (_) => null,
              ),
            ],
          ],
        ));
  }

  Widget _termsRow() {
    return Obx(() => GestureDetector(
          onTap: () => controller.acceptedTerms.toggle(),
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22.w,
                height: 22.w,
                child: Checkbox(
                  value: controller.acceptedTerms.value,
                  onChanged: (value) => controller.acceptedTerms.value = value ?? false,
                  activeColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFF999999)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(fontSize: 10.5.sp, height: 1.4, color: const Color(0xFF666666)),
                      children: [
                        TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        const TextSpan(text: ' and '),
                        TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _createAccountButton() {
    return Obx(() {
      final loading = controller.registerState.isLoading;
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, const Color(0xFFFF8A00)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: loading ? null : controller.register,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: loading
                ? const SizedBox(width: 21, height: 21, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Create Account', style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                      SizedBox(width: 10.w),
                      Icon(Icons.arrow_forward, size: 17.sp, color: Colors.white),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
