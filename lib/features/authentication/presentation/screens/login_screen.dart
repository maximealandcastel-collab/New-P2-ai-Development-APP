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
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _LoginBackdrop()),
            Positioned(
              top: 150.h,
              right: -104.w,
              child: IgnorePointer(
                child: Opacity(
                  opacity: .10,
                  child: Image.asset(
                    'assets/images/training_styles/weight_lifting.png',
                    width: 284.w,
                    height: 440.h,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100.h,
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
                        Colors.white.withValues(alpha: .92),
                        Colors.white.withValues(alpha: .62),
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
              child: Form(
                key: controller.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BrandHeader(primary: primary),
                    SizedBox(height: 20.h),
                    Container(
                      width: 30.w,
                      height: 2.h,
                      color: primary,
                    ),
                    SizedBox(height: 14.h),
                    RichText(
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
                      style: TextStyle(
                        fontSize: 7.8.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.8,
                        color: const Color(0xFF74747E),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _RoleSelector(
                      controller: controller,
                      primary: primary,
                    ),
                    SizedBox(height: 22.h),
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
                        Obx(
                          () => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: controller.toggleSaveLogin,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                color: controller.saveLogin.value
                                    ? primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: controller.saveLogin.value
                                      ? primary
                                      : const Color(0xFFD7D9DE),
                                ),
                                boxShadow: controller.saveLogin.value
                                    ? [
                                        BoxShadow(
                                          color: primary.withValues(alpha: .24),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
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
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: controller.toggleSaveLogin,
                          child: Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF74747F),
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoute.forgotScreen),
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 26.h),
                    Obx(() {
                      final loading =
                          controller.loginState == LoadingState.loading;
                      return Center(
                        child: GestureDetector(
                          onTap: loading ? null : controller.login,
                          child: AnimatedOpacity(
                            opacity: loading ? .72 : 1,
                            duration: const Duration(milliseconds: 180),
                            child: Container(
                              width: 168.w,
                              height: 44.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFFFF9A2F),
                                    Color(0xFFFF6A16),
                                    Color(0xFFFF4C12),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(999.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withValues(alpha: .24),
                                    blurRadius: 16,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: loading
                                    ? SizedBox(
                                        width: 19.w,
                                        height: 19.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'New to P2P Fit? ',
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF8A8B94),
                            ),
                          ),
                          GestureDetector(
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
                            child: Text(
                              'Create account',
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w500,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
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
    return SizedBox(
      height: 64.h,
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
