import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _LoginBackdrop()),
            Positioned(
              top: 118.h,
              right: -92.w,
              child: IgnorePointer(
                child: Opacity(
                  opacity: .085,
                  child: Image.asset(
                    'assets/images/training_styles/weight_lifting.png',
                    width: 276.w,
                    height: 456.h,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 86.h,
              left: 0,
              right: 0,
              height: 560.h,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: .98),
                        Colors.white.withValues(alpha: .94),
                        Colors.white.withValues(alpha: .66),
                      ],
                      stops: const [0, .52, .78, 1],
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(28.w, 16.h, 28.w, 24.h),
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: controller.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BrandHeader(primary: primary),
                    SizedBox(height: 18.h),
                    Container(
                      width: 30.w,
                      height: 2.h,
                      color: primary,
                    ),
                    SizedBox(height: 14.h),
                    _WelcomeHero(primary: primary),
                    SizedBox(height: 22.h),
                    _RoleSelector(
                      controller: controller,
                      primary: primary,
                    ),
                    SizedBox(height: 20.h),
                    const _FieldTitle('EMAIL'),
                    SizedBox(height: 8.h),
                    _CompactLoginField(
                      controller: controller.emailController,
                      hintText: 'Enter your email address',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 20.h),
                    const _FieldTitle('PASSWORD'),
                    SizedBox(height: 8.h),
                    _CompactLoginField(
                      controller: controller.passwordController,
                      hintText: 'Enter your password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => controller.login(),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        _RememberToggle(
                          controller: controller,
                          primary: primary,
                        ),
                        const Spacer(),
                        InkWell(
                          borderRadius: BorderRadius.circular(10.r),
                          onTap: () => Get.toNamed(AppRoute.forgotScreen),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: 44.h),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 26.h),
                    Obx(() {
                      final loading =
                          controller.loginState == LoadingState.loading;
                      return _SignInButton(
                        loading: loading,
                        primary: primary,
                        onPressed: controller.login,
                      );
                    }),
                    SizedBox(height: 30.h),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFDADCE1)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: Text(
                            'O R   C O N T I N U E   W I T H',
                            style: TextStyle(
                              fontSize: 7.7.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.8,
                              color: const Color(0xFF777985),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFDADCE1)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialCircleButton(
                          icon: Icon(
                            Icons.apple,
                            color: Colors.black,
                            size: 25.sp,
                          ),
                          onTap: () => _socialUnavailable('Apple'),
                        ),
                        SizedBox(width: 18.w),
                        _SocialCircleButton(
                          icon: SvgPicture.asset(
                            'assets/icons/google_g.svg',
                            width: 23.r,
                            height: 23.r,
                          ),
                          onTap: () => _socialUnavailable('Google'),
                        ),
                        SizedBox(width: 18.w),
                        _SocialCircleButton(
                          icon: Icon(
                            Icons.facebook_rounded,
                            color: const Color(0xFF0866FF),
                            size: 24.sp,
                          ),
                          onTap: () => _socialUnavailable('Meta'),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    _CreateAccountCard(
                      primary: primary,
                      onTap: () {
                        log('Pre-signup paywall');
                        Get.toNamed(
                          AppRoute.paywallScreen,
                          arguments: {
                            'preSignup': true,
                            'nextRoute': AppRoute.signUpScreen,
                            'freeRoute': AppRoute.signUpScreen,
                          },
                        );
                      },
                    ),
                    SizedBox(height: 28.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _socialUnavailable(String provider) {
    Get.snackbar(
      '$provider sign-in',
      '$provider sign-in is not available yet. Please use email and password.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFCFA),
            Color(0xFFFFF8F3),
          ],
          stops: [0, .46, .78, 1],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Assets.images.logo.path,
              width: 54.w,
              height: 54.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 23.sp,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF080A12),
                    ),
                    children: [
                      const TextSpan(text: 'P2P '),
                      TextSpan(
                        text: 'FIT',
                        style: TextStyle(color: primary),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'T E C H    A I',
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.5,
                    color: const Color(0xFF181A22),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'A\nS T R O N G E R\nY O U\nT O G E T H E R',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 6.5.sp,
                    height: 1.42,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.25,
                    color: const Color(0xFF343640),
                  ),
                ),
                SizedBox(height: 5.h),
                Container(width: 28.w, height: 2.h, color: primary),
              ],
            ),
          ],
        ),
        SizedBox(height: 9.h),
        Text(
          'F I T N E S S   ·   P E O P L E   ·   P R O G R E S S',
          style: TextStyle(
            fontSize: 7.2.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.15,
            color: const Color(0xFF898B96),
          ),
        ),
      ],
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 32.sp,
                      height: 1.05,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1,
                      color: const Color(0xFF090B14),
                    ),
                    children: [
                      const TextSpan(text: 'Welcome '),
                      TextSpan(
                        text: 'back',
                        style: TextStyle(color: primary),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 9.h),
              Text(
                'Sign in to your P2P Fit account.',
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.25,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF71717D),
                ),
              ),
              SizedBox(height: 13.h),
              Text(
                'T R A I N .   C O N N E C T .   A C H I E V E .',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 7.4.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.55,
                  color: const Color(0xFF74747E),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.rotate(
                angle: -.08,
                child: Text(
                  'Better\nTogether',
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: .88,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -.45,
                    color: primary.withValues(alpha: .88),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'F I T N E S S\nB U I L D S\nC O M M U N I T Y',
                style: TextStyle(
                  fontSize: 5.8.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.15,
                  color: const Color(0xFF8A8C95),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldTitle extends StatelessWidget {
  const _FieldTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9.5.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.4,
        color: const Color(0xFF777985),
      ),
    );
  }
}

class _CompactLoginField extends StatefulWidget {
  const _CompactLoginField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_CompactLoginField> createState() => _CompactLoginFieldState();
}

class _CompactLoginFieldState extends State<_CompactLoginField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofillHints: widget.isPassword
          ? const [AutofillHints.password]
          : const [AutofillHints.email],
      style: TextStyle(
        fontSize: 13.sp,
        height: 1.2,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF22242D),
      ),
      cursorColor: primary,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return widget.isPassword
              ? 'Please enter your password'
              : 'Please enter your email address';
        }
        if (widget.isPassword && value.length < 8) {
          return 'Password: 8 characters min!';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFB5B6BE),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .90),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15.h),
        prefixIcon: Icon(
          widget.icon,
          size: 19.sp,
          color: const Color(0xFF696B76),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 48.w),
        suffixIcon: widget.isPassword
            ? IconButton(
                tooltip: _obscureText ? 'Show password' : 'Hide password',
                splashRadius: 18.r,
                onPressed: () => setState(() {
                  _obscureText = !_obscureText;
                }),
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 19.sp,
                  color: const Color(0xFF696B76),
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFE4E5E9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: primary.withValues(alpha: .72)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFE95454)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFE95454)),
        ),
        errorStyle: TextStyle(fontSize: 10.sp, height: 1.1),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.controller,
    required this.primary,
  });

  final LoginController controller;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF0ECE9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB98A63).withValues(alpha: .065),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: _RoleTab(
              label: 'Trainer',
              icon: Icons.fitness_center_rounded,
              controller: controller,
              primary: primary,
            ),
          ),
          Container(
            width: 1,
            height: 30.h,
            color: const Color(0xFFE3E4E8),
          ),
          Expanded(
            child: _RoleTab(
              label: 'User',
              icon: Icons.person_rounded,
              controller: controller,
              primary: primary,
            ),
          ),
          Container(
            width: 1,
            height: 30.h,
            color: const Color(0xFFE3E4E8),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.toNamed(AppRoute.gymGatewayScreen),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apartment_rounded,
                    size: 20.sp,
                    color: const Color(0xFF686A75),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Gym',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF686A75),
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Container(
                    height: 2.h,
                    color: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({
    required this.label,
    required this.icon,
    required this.controller,
    required this.primary,
  });

  final String label;
  final IconData icon;
  final LoginController controller;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedRole == label;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.setRole(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          color: selected
              ? primary.withValues(alpha: .052)
              : Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.04 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: selected ? primary : const Color(0xFF686A75),
                ),
              ),
              SizedBox(height: 5.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: selected ? primary : const Color(0xFF686A75),
                ),
                child: Text(label),
              ),
              SizedBox(height: 8.h),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 1.5.h,
                margin: EdgeInsets.symmetric(horizontal: 14.w),
                color: selected ? primary : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _RememberToggle extends StatelessWidget {
  const _RememberToggle({
    required this.controller,
    required this.primary,
  });

  final LoginController controller;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Semantics(
        checked: controller.saveLogin.value,
        label: 'Remember me',
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: controller.toggleSaveLogin,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 44.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: controller.saveLogin.value ? primary : Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: controller.saveLogin.value
                          ? primary
                          : const Color(0xFFD7D9DE),
                    ),
                    boxShadow: controller.saveLogin.value
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: .20),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: controller.saveLogin.value
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        )
                      : null,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Remember me',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF74747F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatefulWidget {
  const _SignInButton({
    required this.loading,
    required this.primary,
    required this.onPressed,
  });

  final bool loading;
  final Color primary;
  final VoidCallback onPressed;

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        button: true,
        enabled: !widget.loading,
        label: widget.loading ? 'Signing in' : 'Sign in',
        child: AnimatedScale(
          scale: _pressed ? .975 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: widget.loading ? .72 : 1,
            duration: const Duration(milliseconds: 180),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999.r),
                onHighlightChanged: widget.loading
                    ? null
                    : (pressed) => setState(() => _pressed = pressed),
                onTap: widget.loading ? null : widget.onPressed,
                child: Ink(
                  width: 168.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFFFA13A),
                        Color(0xFFFF711C),
                        Color(0xFFFF4E16),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999.r),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primary.withValues(alpha: .20),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: widget.loading
                        ? SizedBox(
                            width: 19.w,
                            height: 19.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 9.w),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateAccountCard extends StatelessWidget {
  const _CreateAccountCard({
    required this.primary,
    required this.onTap,
  });

  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white.withValues(alpha: .84),
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: 48.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFF0ECE9)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'New to P2P Fit? ',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8B94),
                  ),
                ),
                Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w500,
                    color: primary,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 15.sp,
                  color: primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  const _SocialCircleButton({
    required this.icon,
    required this.onTap,
  });

  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .96),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF0F0F2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .045),
              blurRadius: 9,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }
}
