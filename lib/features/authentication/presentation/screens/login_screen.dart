import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

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
              top: 100.h,
              right: -56.w,
              child: IgnorePointer(
                child: Opacity(
                  opacity: .19,
                  child: Image.asset(
                    'assets/images/training_styles/weight_lifting.png',
                    width: 310.w,
                    height: 490.h,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80.h,
              left: 0,
              right: 0,
              height: 540.h,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: .98),
                        Colors.white.withValues(alpha: .80),
                        Colors.white.withValues(alpha: .28),
                      ],
                      stops: const [0, .48, .72, 1],
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 20.h),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: controller.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BrandHeader(primary: primary),
                    SizedBox(height: 16.h),
                    Container(
                      width: 30.w,
                      height: 2.h,
                      color: primary,
                    ),
                    SizedBox(height: 10.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 37.sp,
                          height: 1.02,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -1.3,
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
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to your P2P Fit account.',
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF71717D),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'T R A I N .   C O N N E C T .   A C H I E V E .',
                      style: TextStyle(
                        fontSize: 8.7.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: const Color(0xFF74747E),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _RoleSelector(
                      controller: controller,
                      primary: primary,
                    ),
                    SizedBox(height: 18.h),
                    const _FieldTitle('EMAIL'),
                    SizedBox(height: 9.h),
                    _LoginFieldShell(
                      child: CustomTextField(
                        controller: controller.emailController,
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: const Color(0xFF666975),
                          size: 21.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    const _FieldTitle('PASSWORD'),
                    SizedBox(height: 9.h),
                    _LoginFieldShell(
                      child: CustomTextField(
                        controller: controller.passwordController,
                        hintText: 'Enter your password',
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: const Color(0xFF666975),
                          size: 21.sp,
                        ),
                        isPassword: true,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Obx(
                          () => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: controller.toggleSaveLogin,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 24.w,
                              height: 24.w,
                              decoration: BoxDecoration(
                                color: controller.saveLogin.value
                                    ? primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(7.r),
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
                                      size: 16.sp,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        GestureDetector(
                          onTap: controller.toggleSaveLogin,
                          child: Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 13.sp,
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
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Obx(() {
                      final loading =
                          controller.loginState == LoadingState.loading;
                      return GestureDetector(
                        onTap: loading ? null : controller.login,
                        child: AnimatedOpacity(
                          opacity: loading ? .72 : 1,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            width: double.infinity,
                            height: 52.h,
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
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: .24),
                                  blurRadius: 20,
                                  offset: const Offset(0, 9),
                                ),
                              ],
                            ),
                            child: Center(
                              child: loading
                                  ? SizedBox(
                                      width: 22.w,
                                      height: 22.w,
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
                                            fontSize: 16.5.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 23.sp,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 28.h),
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
                    SizedBox(height: 22.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialCircleButton(
                          icon: Icon(
                            Icons.apple,
                            color: Colors.black,
                            size: 29.sp,
                          ),
                          onTap: () => _socialUnavailable('Apple'),
                        ),
                        SizedBox(width: 20.w),
                        _SocialCircleButton(
                          icon: SvgPicture.asset(
                            'assets/icons/google_g.svg',
                            width: 26.r,
                            height: 26.r,
                          ),
                          onTap: () => _socialUnavailable('Google'),
                        ),
                        SizedBox(width: 24.w),
                        _SocialCircleButton(
                          icon: Icon(
                            Icons.facebook_rounded,
                            color: const Color(0xFF0866FF),
                            size: 28.sp,
                          ),
                          onTap: () => _socialUnavailable('Meta'),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 13.5.sp,
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
                              'Sign up',
                              style: TextStyle(
                                fontSize: 13.5.sp,
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
              width: 62.w,
              height: 62.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 27.sp,
                      height: 1,
                      fontWeight: FontWeight.w800,
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
                SizedBox(height: 8.h),
                Text(
                  'T E C H    A I',
                  style: TextStyle(
                    fontSize: 9.sp,
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
                    fontSize: 7.sp,
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

class _LoginFieldShell extends StatelessWidget {
  const _LoginFieldShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 54.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE4E5E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .018),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
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
      height: 72.h,
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
            height: 34.h,
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
            height: 38.h,
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
                    size: 23.sp,
                    color: const Color(0xFF686A75),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    'Gym',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF686A75),
                    ),
                  ),
                  SizedBox(height: 8.h),
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
                  size: 23.sp,
                  color: selected ? primary : const Color(0xFF686A75),
                ),
              ),
              SizedBox(height: 7.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: selected ? primary : const Color(0xFF686A75),
                ),
                child: Text(label),
              ),
              SizedBox(height: 11.h),
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
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .96),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF0F0F2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }
}
