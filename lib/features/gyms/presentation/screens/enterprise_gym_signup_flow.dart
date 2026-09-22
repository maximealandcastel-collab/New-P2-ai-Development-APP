import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/otp_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_access_recovery_screen.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/enterprise_session_screen.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';

bool enterpriseRoleCanSelfRegister(String role) => role == 'Member';

bool isStrongEnterprisePassword(String password) {
  return password.length >= 8 &&
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[a-z]')) &&
      password.contains(RegExp(r'[0-9]'));
}

class EnterpriseGymSignupFlow extends StatefulWidget {
  final EnterpriseGymModel gym;
  final String initialRole;
  const EnterpriseGymSignupFlow({
    super.key,
    required this.gym,
    this.initialRole = 'Member',
  });

  @override
  State<EnterpriseGymSignupFlow> createState() =>
      _EnterpriseGymSignupFlowState();
}

class _EnterpriseGymSignupFlowState extends State<EnterpriseGymSignupFlow> {
  final PageController _pageController = PageController();
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  int _currentStep = 0;

  final SignUpController _signUpController = SignUpController.to;
  final OtpController _otpController = OtpController.to;

  // Selected values
  late String _selectedRole;
  late String _selectedLocation;

  // Custom focus nodes
  final _otpFocusNode = FocusNode();
  final _accessCodeController = TextEditingController();

  Timer? _resendTimer;
  final ValueNotifier<int> _resendSecondsNotifier = ValueNotifier(30);
  final ValueNotifier<bool> _canResendNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _selectedLocation = widget.gym.name;
    _signUpController.configureEntry({
      'tenantId': widget.gym.tenantId,
      'gymName': widget.gym.name,
      'paywallPassed': true,
      'role': 'User',
    });
    // Clear out standard P2P fields
    _signUpController.firstNameController.clear();
    _signUpController.lastNameController.clear();
    _signUpController.emailController.clear();
    _signUpController.phoneController.clear();
    _signUpController.genderController.clear();
    _signUpController.passwordController.clear();
    _signUpController.confirmPasswordController.clear();
    _signUpController.acceptedTerms.value = false;
    _otpController.otpController.clear();
  }

  void _startResendTimer() {
    _resendSecondsNotifier.value = 30;
    _canResendNotifier.value = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSecondsNotifier.value > 0) {
        _resendSecondsNotifier.value--;
      } else {
        _canResendNotifier.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> _handleResend() async {
    if (!_canResendNotifier.value) return;
    _startResendTimer();
    try {
      await Get.find<AuthService>().resendOtp(
        email: _signUpController.emailController.text.trim(),
      );
      Get.snackbar(
        'OTP Sent',
        'A new verification code has been sent to your email.',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP. Please try again.');
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _resendSecondsNotifier.dispose();
    _canResendNotifier.dispose();
    _otpFocusNode.dispose();
    _accessCodeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  String _tenantRoleKey(String role) {
    switch (role) {
      case 'Trainer': return 'trainer';
      case 'Gym Staff': return 'staff';
      case 'Admin': return 'admin';
      case 'Gym Partner': return 'owner';
      default: return 'member';
    }
  }

  Future<void> _submitRegistration() async {
    if (!enterpriseRoleCanSelfRegister(_selectedRole) &&
        _accessCodeController.text.trim().length < 6) {
      Get.snackbar('Invitation required', 'Use the gym-issued code for this role.');
      return;
    }
    final String roleToSend;
    switch (_selectedRole) {
      case 'Member':
        roleToSend = 'User';
        break;
      case 'Trainer':
        roleToSend = 'Trainer';
        break;
      case 'Gym Staff':
      case 'Admin':
      case 'Gym Partner':
        roleToSend = 'User';
        break;
      default:
        roleToSend = _selectedRole;
    }
    _signUpController.changeRole(roleToSend);
    _signUpController.configureTenantAccess(
      tenantId: widget.gym.tenantId,
      tenantRole: _tenantRoleKey(_selectedRole),
      accessCode: _accessCodeController.text.trim(),
    );
    final success = await _signUpController.register(
      navigateOnSuccess: false,
    );
    if (success) {
      _startResendTimer();
      _nextStep();
    } else {
      debugPrint(success.toString());
      debugPrint("Registration failed");
    }
  }

  Future<void> _submitOtp() async {
    final tenantId = widget.gym.tenantId;
    if (tenantId == null || tenantId.isEmpty) {
      Get.snackbar(
        'Unable to verify gym',
        'This gym is not configured for signup.',
      );
      return;
    }
    final success = await _otpController.otpVerify(
      requiredTenantId: tenantId,
      formKey: _otpFormKey,
    );
    if (success) {
      _nextStep();
    }
  }

  Future<void> _finish() async {
    final tenantId = widget.gym.tenantId;
    if (tenantId == null || tenantId.isEmpty) {
      Get.snackbar(
        'Account created',
        'Your account is ready, but this gym is not configured yet.',
      );
      return;
    }


    try {
      await enterEnterprise(tenantId);
    } catch (failure) {
      Get.offAll(
        () => EnterpriseAccessRecoveryScreen(
          initialError: failure,
          onRetry: () => enterEnterprise(tenantId),
          onSignOut: () async {
            await Get.find<AuthService>().logout();
            Get.offAllNamed(AppRoute.loginScreen);
          },
        ),
      );
    }
  }

  Color get _actionColor => widget.gym.id == 'kmf_fitness_club'
      ? const Color(0xFF22C55E)
      : widget.gym.brandColor;

  Widget _buildStepIndicator() {
    // Top progress bar: 6 segments (Role, Location, Info, Password, Terms, OTP). Account Created has none.
    if (_currentStep == 6) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: List.generate(6, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              height: 4.h,
              decoration: BoxDecoration(
                color: isActive ? _actionColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: AppFontWeight.section,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Powered by ',
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          GymBrandLogo(
            gym: EnterpriseGymModel.partners.firstWhere(
              (g) => g.id == 'p2p_fit_factor',
            ),
            size: 14.r,
            borderRadius: 4.r,
          ),
          SizedBox(width: 4.w),
          Text(
            'P2P Fit Tech AI',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: AppFontWeight.section,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep < 6
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _buildRoleStep(),
                  _buildLocationStep(),
                  _buildPersonalInfoStep(),
                  _buildPasswordStep(),
                  _buildTermsStep(),
                  _buildOtpStep(),
                  _buildSuccessStep(),
                ],
              ),
            ),
            if (_currentStep < 6) _buildFooter(),
          ],
        ),
      ),
    );
  }

  // --- STEPS ---

  Widget _buildRoleStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            'Create your account',
            'Join the ${widget.gym.name} community.',
          ),
          _buildRoleOption(
            'Member',
            'Access workouts, classes, trainers & more',
            Icons.person_outline,
          ),
          _buildRoleOption(
            'Trainer',
            'Coach, manage clients, and grow',
            Icons.fitness_center,
          ),
          _buildRoleOption(
            'Gym Staff',
            'Manage operations and members',
            Icons.badge_outlined,
          ),
          _buildRoleOption(
            'Admin',
            'Full facility management',
            Icons.settings_outlined,
          ),
          _buildRoleOption(
            'Gym Partner',
            'Owner and executive facility access',
            Icons.business_outlined,
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: _accessCodeController,
              obscureText: true,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Professional access code',
                helperText: 'Use the code for ' + widget.gym.name +
                    ' and your selected role.',
                prefixIcon: const Icon(Icons.verified_user_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _actionColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: _accessCodeController.text.trim().length >= 6
                    ? _nextStep
                    : null,
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String role, String description, IconData icon) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedRole = role;
        _accessCodeController.clear();
      }),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? _actionColor : Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? _actionColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _actionColor),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontWeight: AppFontWeight.section,
                      fontSize: 16.sp,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isSelected ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Select your gym', 'Choose your home location.'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search locations...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          _buildLocationOption(widget.gym.name, widget.gym.address),
          // Additional mock locations if YMCA
          if (widget.gym.id == 'ymca_yonkers') ...[
            _buildLocationOption(
              'YMCA New Rochelle',
              '50 Weyman Ave, New Rochelle, NY 10805',
            ),
            _buildLocationOption(
              'YMCA White Plains',
              '250 Mamaroneck Ave, White Plains, NY 10605',
            ),
          ],
          SizedBox(height: 40.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _actionColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: _nextStep,
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationOption(String name, String address) {
    final isSelected = _selectedLocation == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedLocation = name),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? _actionColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            GymBrandLogo(gym: widget.gym, size: 40.r, borderRadius: 8.r),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: AppFontWeight.section,
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    address,
                    style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? _actionColor : Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _personalInfoFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              'Your information',
              'Create your ${widget.gym.name} account.',
            ),
            _buildTextField(
              'First name',
              'John',
              Icons.person_outline,
              _signUpController.firstNameController,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            _buildTextField(
              'Last name',
              'Doe',
              Icons.person_outline,
              _signUpController.lastNameController,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            _buildTextField(
              'Email',
              'john.doe@email.com',
              Icons.email_outlined,
              _signUpController.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !GetUtils.isEmail(v))
                  ? 'Valid email required'
                  : null,
            ),
            _buildTextField(
              'Phone number',
              '+1 (914) 123-4567',
              Icons.phone_outlined,
              _signUpController.phoneController,
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            _buildDatePickerField(
              'Date of birth',
              'MM/DD/YYYY',
              Icons.calendar_today_outlined,
              _signUpController.dobController,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            _buildGenderDropdownField(
              'Gender',
              'Select gender',
              Icons.person_pin_outlined,
              _signUpController.genderController,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _actionColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    if (_personalInfoFormKey.currentState?.validate() ??
                        false) {
                      _nextStep();
                    }
                  },
                  child: Text(
                    'Continue',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdownField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    const options = [
      'Male',
      'Female',
      'Not prefer to say',
    ];

    final currentVal = controller.text.trim();
    final selectedVal = options.contains(currentVal) ? currentVal : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            initialValue: selectedVal,
            validator: validator,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            items: options.map((opt) {
              return DropdownMenuItem<String>(
                value: opt,
                child: Text(opt, style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                controller.text = v;
              }
            },
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(
                  const Duration(days: 365 * 18),
                ),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(primary: _actionColor),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                controller.text =
                    "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: controller,
                validator: validator,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: Icon(icon, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Form(
      key: _passwordFormKey,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _signUpController.passwordController,
          _signUpController.confirmPasswordController,
        ]),
        builder: (context, _) {
          final pwd = _signUpController.passwordController.text;
          final hasLength = pwd.length >= 8;
          final hasUpper = RegExp(r'[A-Z]').hasMatch(pwd);
          final hasLower = RegExp(r'[a-z]').hasMatch(pwd);
          final hasNumber = RegExp(r'[0-9]').hasMatch(pwd);
          final isValid =
              hasLength &&
              hasUpper &&
              hasLower &&
              hasNumber &&
              pwd == _signUpController.confirmPasswordController.text;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader('Create a password', 'Keep your account secure.'),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _signUpController.passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confirm password',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _signUpController.confirmPasswordController,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        enableSuggestions: false,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      _buildPasswordRule('At least 8 characters', hasLength),
                      _buildPasswordRule('One uppercase letter', hasUpper),
                      _buildPasswordRule('One lowercase letter', hasLower),
                      _buildPasswordRule('One number', hasNumber),
                      _buildPasswordRule(
                        'Passwords match',
                        pwd.isNotEmpty &&
                            pwd ==
                                _signUpController
                                    .confirmPasswordController
                                    .text,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _actionColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: isValid ? _nextStep : null,
                      child: Text(
                        'Continue',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordRule(String rule, bool met) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            color: met ? Colors.green : Colors.grey,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            rule,
            style: TextStyle(
              fontSize: 12.sp,
              color: met ? Colors.black87 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsStep() {
    return Obx(
      () => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Terms & Privacy', 'Review and accept to continue.'),
            _buildTermItem('Terms of Service'),
            _buildTermItem('Privacy Policy'),
            _buildTermItem('${widget.gym.name} Member Agreement'),
            _buildTermItem('Data Sharing & Health Privacy'),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Checkbox(
                    value: _signUpController.acceptedTerms.value,
                    onChanged: (val) =>
                        _signUpController.acceptedTerms.value = val ?? false,
                    activeColor: _actionColor,
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the terms and conditions and acknowledge the privacy policy.',
                      style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _actionColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed:
                      _signUpController.acceptedTerms.value &&
                          _signUpController.registerState !=
                              LoadingState.loading
                      ? _submitRegistration
                      : null,
                  child: _signUpController.registerState == LoadingState.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
          title: Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ),
        Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Form(
      key: _otpFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              'Verify your email',
              'We sent a 6-digit code to\n${_signUpController.emailController.text}',
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Center(
                child: TextFormField(
                  controller: _otpController.otpController,
                  focusNode: _otpFocusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: TextStyle(fontSize: 24.sp, letterSpacing: 8.w),
                  decoration: InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (v) => v!.length == 6 ? null : 'Required',
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  _resendSecondsNotifier,
                  _canResendNotifier,
                ]),
                builder: (context, _) {
                  final canResend = _canResendNotifier.value;
                  return TextButton(
                    onPressed: canResend ? _handleResend : null,
                    child: Text(
                      canResend
                          ? 'Resend code'
                          : 'Resend code (${_resendSecondsNotifier.value}s)',
                      style: TextStyle(
                        color: canResend ? _actionColor : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _actionColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: _otpController.otpState == LoadingState.loading
                        ? null
                        : _submitOtp,
                    child: _otpController.otpState == LoadingState.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: _prevStep,
                child: Text(
                  'Change email',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30.r),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.green, size: 60.sp),
          ),
          SizedBox(height: 40.h),
          Text(
            'Account created!',
            style: TextStyle(fontSize: 24.sp, fontWeight: AppFontWeight.section),
          ),
          SizedBox(height: 8.h),
          Text(
            'Welcome to\n${widget.gym.name}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              color: _actionColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              "You're now part of a stronger, healthier community.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.black54),
            ),
          ),
          SizedBox(height: 60.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _actionColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: _finish,
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
