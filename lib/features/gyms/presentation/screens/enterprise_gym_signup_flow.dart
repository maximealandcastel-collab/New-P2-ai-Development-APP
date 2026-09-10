import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/otp_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/sign_up_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

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
  const EnterpriseGymSignupFlow({super.key, required this.gym, this.initialRole = 'Member'});

  @override
  State<EnterpriseGymSignupFlow> createState() => _EnterpriseGymSignupFlowState();
}

class _EnterpriseGymSignupFlowState extends State<EnterpriseGymSignupFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  final SignUpController _signUpController = SignUpController.to;
  final OtpController _otpController = OtpController.to;

  // Selected values
  late String _selectedRole;
  late String _selectedLocation;
  
  // Custom focus nodes
  final _otpFocusNode = FocusNode();

  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResend = false;

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
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleResend() async {
    if (!_canResend) return;
    _startResendTimer();
    try {
      await Get.find<AuthService>().resendOtp(email: _signUpController.emailController.text.trim());
      Get.snackbar('OTP Sent', 'A new verification code has been sent to your email.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP. Please try again.');
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpFocusNode.dispose();
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

  Future<void> _submitRegistration() async {
    _signUpController.changeRole(_selectedRole == 'Member' ? 'User' : _selectedRole);
    final success = await _signUpController.register(navigateOnSuccess: false);
    if (success) {
      _startResendTimer();
      _nextStep();
    }
  }

  Future<void> _submitOtp() async {
    final tenantId = widget.gym.tenantId;
    if (tenantId == null || tenantId.isEmpty) {
      Get.snackbar('Unable to verify gym', 'This gym is not configured for signup.');
      return;
    }
    final success = await _otpController.otpVerify(requiredTenantId: tenantId);
    if (success) {
      _nextStep();
    }
  }

  void _finish() {
    if (_otpController.isTrainer()) {
      Get.offAllNamed(AppRoute.trainerCompleteProfileScreen);
    } else {
      ProfileCompleteController.to.applyMemberDraft(_signUpController.takeMemberDraft());
      Get.offAllNamed(AppRoute.userCompleteProfileScreen);
    }
  }

  void _showRestrictedRoleDialog(String role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$role access is invitation-only'),
        content: Text(
          'Authorized ${widget.gym.name} business owners and staff should sign in with their existing account or contact their administrator.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back(); // Go back to login screen
            },
            child: const Text('Go to Sign In'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

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
                color: isActive ? widget.gym.brandColor : Colors.grey[300],
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
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black54,
            ),
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
            gym: EnterpriseGymModel.partners.firstWhere((g) => g.id == 'p2p_fit_factor'),
            size: 14.r,
            borderRadius: 4.r,
          ),
          SizedBox(width: 4.w),
          Text(
            'P2P Fit Tech AI',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black87),
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
          _buildHeader('Create your account', 'Join the ${widget.gym.name} community.'),
          _buildRoleOption('Member', 'Access workouts, classes, trainers & more', Icons.person_outline),
          _buildRoleOption('Trainer', 'Coach, manage clients, and grow', Icons.fitness_center),
          _buildRoleOption('Gym Staff', 'Manage operations and members', Icons.badge_outlined),
          _buildRoleOption('Admin', 'Full facility management', Icons.settings_outlined),
          SizedBox(height: 40.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.gym.brandColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () {
                  if (!enterpriseRoleCanSelfRegister(_selectedRole)) {
                    _showRestrictedRoleDialog(_selectedRole);
                  } else {
                    _nextStep();
                  }
                },
                child: Text('Continue', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRoleOption(String role, String description, IconData icon) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? widget.gym.brandColor : Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? widget.gym.brandColor : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: widget.gym.brandColor),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
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
            )
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
             _buildLocationOption('YMCA New Rochelle', '50 Weyman Ave, New Rochelle, NY 10805'),
             _buildLocationOption('YMCA White Plains', '250 Mamaroneck Ave, White Plains, NY 10605'),
          ],
          SizedBox(height: 40.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.gym.brandColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: _nextStep,
                child: Text('Continue', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
              ),
            ),
          )
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
          border: Border.all(color: isSelected ? widget.gym.brandColor : Colors.grey[300]!),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black87),
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
              color: isSelected ? widget.gym.brandColor : Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _signUpController.registerFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Your information', 'Create your ${widget.gym.name} account.'),
            _buildTextField('First name', 'John', Icons.person_outline, _signUpController.firstNameController, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
            _buildTextField('Last name', 'Doe', Icons.person_outline, _signUpController.lastNameController, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
            _buildTextField('Email', 'john.doe@email.com', Icons.email_outlined, _signUpController.emailController, keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || !GetUtils.isEmail(v)) ? 'Valid email required' : null),
            _buildTextField('Phone number', '+1 (914) 123-4567', Icons.phone_outlined, _signUpController.phoneController, keyboardType: TextInputType.phone, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
            _buildDatePickerField('Date of birth', 'MM/DD/YYYY', Icons.calendar_today_outlined, _signUpController.dobController, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.gym.brandColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () {
                    if (_signUpController.registerFormKey.currentState?.validate() ?? false) {
                      _nextStep();
                    }
                  },
                  child: Text('Continue', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, String hint, IconData icon, TextEditingController controller, {String? Function(String?)? validator}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: widget.gym.brandColor,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                controller.text = "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
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

  Widget _buildTextField(String label, String hint, IconData icon, TextEditingController controller, {bool obscure = false, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
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
      key: GlobalKey<FormState>(), // Use local form key
      child: StatefulBuilder(
        builder: (context, setState) {
          final pwd = _signUpController.passwordController.text;
          final hasLength = pwd.length >= 8;
          final hasUpper = RegExp(r'[A-Z]').hasMatch(pwd);
          final hasLower = RegExp(r'[a-z]').hasMatch(pwd);
          final hasNumber = RegExp(r'[0-9]').hasMatch(pwd);
          final isValid = hasLength && hasUpper && hasLower && hasNumber && pwd == _signUpController.confirmPasswordController.text;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader('Create a password', 'Keep your account secure.'),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Password', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _signUpController.passwordController,
                        obscureText: true,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
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
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Confirm password', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _signUpController.confirmPasswordController,
                        obscureText: true,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
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
                      _buildPasswordRule('Passwords match', pwd.isNotEmpty && pwd == _signUpController.confirmPasswordController.text),
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
                        backgroundColor: widget.gym.brandColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: isValid ? _nextStep : null,
                      child: Text('Continue', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
                    ),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildPasswordRule(String rule, bool met) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(met ? Icons.check_circle : Icons.radio_button_unchecked, color: met ? Colors.green : Colors.grey, size: 16.sp),
          SizedBox(width: 8.w),
          Text(rule, style: TextStyle(fontSize: 12.sp, color: met ? Colors.black87 : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildTermsStep() {
    return Obx(() => SingleChildScrollView(
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
                  onChanged: (val) => _signUpController.acceptedTerms.value = val ?? false,
                  activeColor: widget.gym.brandColor,
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
                  backgroundColor: widget.gym.brandColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: _signUpController.acceptedTerms.value && _signUpController.registerState != LoadingState.loading
                    ? _submitRegistration
                    : null,
                child: _signUpController.registerState == LoadingState.loading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Continue', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    ));
  }

  Widget _buildTermItem(String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
          title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ),
        Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Form(
      key: _otpController.otpFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Verify your email', 'We sent a 6-digit code to\n${_signUpController.emailController.text}'),
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
              child: TextButton(
                onPressed: _canResend ? _handleResend : null,
                child: Text(
                  _canResend ? 'Resend code' : 'Resend code (${_resendSeconds}s)',
                  style: TextStyle(
                    color: _canResend ? widget.gym.brandColor : Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.gym.brandColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: _otpController.otpState == LoadingState.loading ? null : _submitOtp,
                  child: _otpController.otpState == LoadingState.loading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Verify', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
                )),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: _prevStep,
                child: Text('Change email', style: TextStyle(color: Colors.grey)),
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
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Welcome to\n${widget.gym.name}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.sp, color: widget.gym.brandColor, fontWeight: FontWeight.w600),
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
                  backgroundColor: widget.gym.brandColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: _finish,
                child: Text('Continue', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
