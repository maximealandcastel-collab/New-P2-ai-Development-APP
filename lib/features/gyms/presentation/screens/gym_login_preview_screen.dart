import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';

/// Gym-branded login screen that stays inside the P2P Fit Tech AI design system.
///
/// The gym's logo + color personalize the experience — they do NOT replace P2P.
/// Background stays white. Actions stay P2P orange. Layout stays P2P standard.
class GymLoginPreviewScreen extends StatefulWidget {
  final EnterpriseGymModel gym;
  const GymLoginPreviewScreen({super.key, required this.gym});

  @override
  State<GymLoginPreviewScreen> createState() => _GymLoginPreviewScreenState();
}

class _GymLoginPreviewScreenState extends State<GymLoginPreviewScreen> {
  static const _kOrange = Color(0xFFFD7B00);
  static const _kBg = Color(0xFFF7F8FA);
  bool _isLogin = true;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final gym = widget.gym;
    if (gym.id == 'kmf_fitness_club') {
      return _KmfFitnessLoginScreen(gym: gym);
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────────────────
              _TopBar(gym: gym),

              SizedBox(height: 8.h),

              // ── Gym identity card ─────────────────────────────────────
              _GymIdentityBanner(gym: gym),

              SizedBox(height: 20.h),

              // ── Login / Signup toggle ─────────────────────────────────
              _buildToggle(),

              SizedBox(height: 20.h),

              // ── Auth form ─────────────────────────────────────────────
              _buildForm(gym),

              SizedBox(height: 24.h),

              // ── Social divider ────────────────────────────────────────
              _buildDivider(),

              SizedBox(height: 16.h),

              // ── Social buttons ────────────────────────────────────────
              _buildSocialButtons(),

              SizedBox(height: 32.h),

              // ── P2P footer ────────────────────────────────────────────
              _P2PFooter(gym: gym),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Toggle: Login / Sign Up ───────────────────────────────────────────────

  Widget _buildToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _togglePill('Login', _isLogin, () => setState(() => _isLogin = true)),
            _togglePill('Sign Up', !_isLogin, () => setState(() => _isLogin = false)),
          ],
        ),
      ),
    );
  }

  Widget _togglePill(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: active ? _kOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(30.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: AppFontWeight.label,
              color: active ? Colors.white : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }

  // ── Auth form ─────────────────────────────────────────────────────────────

  Widget _buildForm(EnterpriseGymModel gym) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLogin
                  ? 'Welcome back'
                  : 'Join ${gym.name}',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: AppFontWeight.display,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _isLogin
                  ? 'Sign in to your ${gym.name} account'
                  : 'Create your ${gym.name} membership',
              style: TextStyle(fontSize: 13.sp, color: Colors.black45),
            ),

            SizedBox(height: 20.h),

            if (!_isLogin) ...[
              _field(
                icon: Icons.person_outline_rounded,
                hint: 'Full name',
              ),
              SizedBox(height: 12.h),
            ],

            _field(
              icon: Icons.email_outlined,
              hint: 'Email address',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12.h),
            _field(
              icon: Icons.lock_outline_rounded,
              hint: 'Password',
              obscure: _obscure,
              suffix: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black38,
                  size: 18.sp,
                ),
              ),
            ),

            if (!_isLogin) ...[
              SizedBox(height: 12.h),
              _field(
                icon: Icons.lock_outline_rounded,
                hint: 'Confirm password',
                obscure: true,
              ),
            ],

            if (_isLogin) ...[
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _kOrange,
                    fontWeight: AppFontWeight.label,
                  ),
                ),
              ),
            ],

            SizedBox(height: 20.h),

            // Primary CTA — always P2P orange
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                onPressed: () => Get.toNamed(
                  _isLogin ? AppRoute.loginScreen : AppRoute.signUpScreen,
                ),
                child: Text(
                  _isLogin ? 'Login' : 'Create Account',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: AppFontWeight.label,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black38, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              hint,
              style: TextStyle(color: Colors.black38, fontSize: 14.sp),
            ),
          ),
          if (suffix != null) suffix,
        ],
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.black12, thickness: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              'or continue with',
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black38,
                  fontWeight: AppFontWeight.body),
            ),
          ),
          Expanded(child: Divider(color: Colors.black12, thickness: 1)),
        ],
      ),
    );
  }

  // ── Social buttons ────────────────────────────────────────────────────────

  Widget _buildSocialButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _socialBtn(
              label: 'Apple',
              icon: Icons.apple_rounded,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _socialBtn(
              label: 'Google',
              icon: Icons.g_mobiledata_rounded,
              color: const Color(0xFF4285F4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialBtn({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: AppFontWeight.label,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _KmfFitnessLoginScreen extends StatefulWidget {
  final EnterpriseGymModel gym;

  const _KmfFitnessLoginScreen({required this.gym});

  @override
  State<_KmfFitnessLoginScreen> createState() =>
      _KmfFitnessLoginScreenState();
}

class _KmfFitnessLoginScreenState extends State<_KmfFitnessLoginScreen> {
  static const _green = Color(0xFF39FF14);
  static const _black = Color(0xFF090A09);
  final LoginController _controller = LoginController.to;
  String _entryRole = 'Member';

  void _selectRole(String role) {
    setState(() => _entryRole = role);
    _controller.setRole(
      switch (role) {
        'Trainer' => 'Trainer',
        'Admin' => 'Admin',
        _ => 'User',
      },
    );
  }

  void _openSignUp() {
    if (_entryRole == 'Admin') {
      Get.snackbar(
        'Admin accounts are invitation-only',
        'Authorized KMF business owners should sign in with their existing account.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: _black,
        margin: EdgeInsets.all(16.r),
      );
      return;
    }
    Get.toNamed(
      AppRoute.signUpScreen,
      arguments: <String, dynamic>{
        'tenantId': 'kmf-fitness',
        if (_entryRole == 'Trainer') 'trainerEntry': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _black,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 30.h),
          child: Form(
            key: _controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Center(
                  child: Container(
                    width: 126.r,
                    height: 126.r,
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(color: _green, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _green.withOpacity(0.18),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: GymBrandLogo(
                      gym: widget.gym,
                      size: 104.r,
                      borderRadius: 20.r,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'KMF Fitness',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29.sp,
                    height: 1.05,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'Keep Moving Forward',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _green,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sign in',
                        style: TextStyle(
                          color: _black,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'Use your P2P FitTech AI account.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Row(
                        children: ['Member', 'Trainer', 'Admin']
                            .map(
                              (role) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                                  child: _KmfRoleButton(
                                    label: role,
                                    selected: _entryRole == role,
                                    onTap: () => _selectRole(role),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      if (_entryRole == 'Admin') ...[
                        SizedBox(height: 9.h),
                        Text(
                          'Admin access is verified from your authorized owner account after sign in.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 11.sp,
                            height: 1.35,
                          ),
                        ),
                      ],
                      SizedBox(height: 18.h),
                      _KmfTextField(
                        controller: _controller.emailController,
                        label: 'Email',
                        hint: 'Enter your email address',
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Enter your email address';
                          if (!GetUtils.isEmail(email)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14.h),
                      _KmfTextField(
                        controller: _controller.passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                        validator: (value) => (value ?? '').isEmpty
                            ? 'Enter your password'
                            : null,
                      ),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              Get.toNamed(AppRoute.forgotScreen),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Color(0xFF187900),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Obx(() {
                        final loading =
                            _controller.loginState == LoadingState.loading;
                        return SizedBox(
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed:
                                loading ? null : () => _controller.login(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: _black,
                              disabledBackgroundColor:
                                  _green.withOpacity(0.45),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: loading
                                ? SizedBox(
                                    width: 22.r,
                                    height: 22.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: _black,
                                    ),
                                  )
                                : Text(
                                    'Sign in as $_entryRole',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      }),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New to KMF? ',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: _openSignUp,
                            child: Text(
                              _entryRole == 'Admin'
                                  ? 'Owner access'
                                  : 'Create account',
                              style: TextStyle(
                                color: const Color(0xFF187900),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/app_icon.png',
                      width: 23.r,
                      height: 23.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Powered by P2P FitTech AI',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KmfRoleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _KmfRoleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF39FF14) : const Color(0xFFF0F2EF),
      borderRadius: BorderRadius.circular(11.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 11.h),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF090A09),
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _KmfTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const _KmfTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 7.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          textInputAction:
              obscureText ? TextInputAction.done : TextInputAction.next,
          onFieldSubmitted:
              obscureText ? (_) => LoginController.to.login() : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.black45),
            filled: true,
            fillColor: const Color(0xFFF3F5F2),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.r),
              borderSide:
                  const BorderSide(color: Color(0xFF39FF14), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final EnterpriseGymModel gym;
  const _TopBar({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.black87, size: 16.sp),
            ),
          ),

          const Spacer(),

          // P2P + Gym co-brand
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7.r),
                ),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Text('×',
                    style:
                        TextStyle(color: Colors.black26, fontSize: 12.sp)),
              ),
              GymBrandLogo(
                gym: gym,
                size: 28.r,
                borderRadius: 7.r,
              ),
            ],
          ),

          const Spacer(),

          // Live demo badge
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5.r,
                  height: 5.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text('Live',
                    style: TextStyle(
                        color: const Color(0xFF2E7D32),
                        fontSize: 11.sp,
                        fontWeight: AppFontWeight.label)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gym identity banner ───────────────────────────────────────────────────────

class _GymIdentityBanner extends StatelessWidget {
  final EnterpriseGymModel gym;
  const _GymIdentityBanner({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            GymBrandLogo(
              gym: gym,
              size: 54.r,
              borderRadius: 14.r,
            ),

            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gym.name,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: AppFontWeight.title,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    gym.category,
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.black45),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 12.sp,
                          color: const Color(0xFFFFAB00)),
                      SizedBox(width: 3.w),
                      Text(
                        '${gym.rating.toStringAsFixed(1)}  ·  ${gym.memberCount}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.black45,
                          fontWeight: AppFontWeight.body,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // YOUR GYM / PARTNER badge
            gym.isOwnGym
                ? Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFD7B00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text('YOUR\nGYM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color(0xFFFD7B00),
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.3)),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text('LICENSED\nPARTNER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color(0xFF2E7D32),
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.3)),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── P2P footer ────────────────────────────────────────────────────────────────

class _P2PFooter extends StatelessWidget {
  final EnterpriseGymModel gym;
  const _P2PFooter({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                color: const Color(0xFFFD7B00),
                borderRadius: BorderRadius.circular(5.r),
              ),
              alignment: Alignment.center,
              child: Text('P2',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w700)),
            ),
            SizedBox(width: 6.w),
            Text(
              'Powered by P2P FitTech AI',
              style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.black45,
                  fontWeight: AppFontWeight.body),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '${gym.name} · IP Licensed · Enterprise Partner',
          style: TextStyle(fontSize: 10.sp, color: Colors.black26),
        ),
      ],
    );
  }
}
