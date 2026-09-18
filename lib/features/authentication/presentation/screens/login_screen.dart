import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
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
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFFFFCF9),
                      Color(0xFFFFFFFF),
                      Color(0xFFFFF1E8),
                    ],
                    stops: [0, .32, .72, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -12.h,
              right: -72.w,
              child: Opacity(
                opacity: .17,
                child: Image.asset(
                  'assets/images/training_styles/weight_lifting.png',
                  width: 285.w,
                  height: 360.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(22.w, 16.h, 22.w, 28.h),
              child: Form(
                key: controller.loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          Assets.images.logo.path,
                          width: 68.w,
                          height: 68.w,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 29.sp,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF050816),
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
                            SizedBox(height: 6.h),
                            Text(
                              'T E C H   A I',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                                color: const Color(0xFF18181B),
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
                                fontSize: 7.5.sp,
                                height: 1.45,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: const Color(0xFF27272A),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              width: 28.w,
                              height: 2.h,
                              color: primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'F I T N E S S   •   P E O P L E   •   P R O G R E S S',
                      style: TextStyle(
                        fontSize: 7.6.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.1,
                        color: const Color(0xFF8A8A93),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 36.sp,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.4,
                          color: const Color(0xFF050816),
                        ),
                        children: [
                          const TextSpan(text: 'Welcome '),
                          TextSpan(
                            text: 'Back',
                            style: TextStyle(color: primary),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 9.h),
                    Text(
                      'Sign in to your P2P Fit account',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5B5B62),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Train. Connect. Achieve.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFA1A1AA),
                      ),
                    ),
                    SizedBox(height: 26.h),
                    _RoleSelector(
                      controller: controller,
                      primary: primary,
                    ),
                    SizedBox(height: 28.h),
                    const _FieldTitle('Email'),
                    SizedBox(height: 8.h),
                    _GlossyField(
                      child: CustomTextField(
                        controller: controller.emailController,
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: const Color(0xFF626269),
                          size: 22.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 22.h),
                    const _FieldTitle('Password'),
                    SizedBox(height: 8.h),
                    _GlossyField(
                      child: CustomTextField(
                        controller: controller.passwordController,
                        hintText: 'Enter your password',
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: const Color(0xFF626269),
                          size: 22.sp,
                        ),
                        isPassword: true,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Obx(
                          () => GestureDetector(
                            onTap: controller.toggleSaveLogin,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 24.w,
                              height: 24.w,
                              decoration: BoxDecoration(
                                color: controller.saveLogin.value
                                    ? primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: controller.saveLogin.value
                                      ? primary
                                      : const Color(0xFFD4D4D8),
                                ),
                                boxShadow: controller.saveLogin.value
                                    ? [
                                        BoxShadow(
                                          color: primary.withValues(alpha: .22),
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
                                      size: 17.sp,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(width: 9.w),
                        GestureDetector(
                          onTap: controller.toggleSaveLogin,
                          child: Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF18181B),
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
                        child: Container(
                          width: double.infinity,
                          height: 58.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF9A32),
                                primary,
                                const Color(0xFFFF4A16),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: const Color(0xFFFFB06D),
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: .32),
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
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 22.sp,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 22.h),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFD8D8DC)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF71717A),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFD8D8DC)),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            label: 'Google',
                            icon: SvgPicture.asset(
                              'assets/icons/google_g.svg',
                              width: 21.r,
                              height: 21.r,
                            ),
                            onTap: () => _socialUnavailable('Google'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _SocialButton(
                            label: 'Apple',
                            icon: Icon(
                              Icons.apple,
                              color: Colors.black,
                              size: 24.sp,
                            ),
                            onTap: () => _socialUnavailable('Apple'),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _SocialButton(
                            label: 'Microsoft',
                            icon: Icon(
                              Icons.window_rounded,
                              color: primary,
                              size: 22.sp,
                            ),
                            onTap: () => _socialUnavailable('Microsoft'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 18.h,
                        horizontal: 14.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .035),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF18181B),
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
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Row(
                      children: [
                        const Expanded(
                          child: _FooterBenefit(
                            icon: Icons.bar_chart_rounded,
                            title: 'TRAIN\nSMARTER',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28.h,
                          color: const Color(0xFFFFA367),
                        ),
                        const Expanded(
                          child: _FooterBenefit(
                            icon: Icons.groups_rounded,
                            title: 'CONNECT\nFASTER',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28.h,
                          color: const Color(0xFFFFA367),
                        ),
                        const Expanded(
                          child: _FooterBenefit(
                            icon: Icons.emoji_events_outlined,
                            title: 'ACHIEVE\nMORE',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
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

class _FieldTitle extends StatelessWidget {
  const _FieldTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF111118),
        ),
      );
}

class _GlossyField extends StatelessWidget {
  const _GlossyField({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .94),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFE1E3E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .035),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: child,
      );
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.controller,
    required this.primary,
  });

  final LoginController controller;
  final Color primary;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .92),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: const Color(0xFFE7E7EA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
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
            Expanded(
              child: _RoleTab(
                label: 'User',
                icon: Icons.person_rounded,
                controller: controller,
                primary: primary,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoute.gymGatewayScreen),
                child: SizedBox(
                  height: 70.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business_rounded,
                        size: 24.sp,
                        color: const Color(0xFF4B4B50),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'Gym',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3F3F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
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
  Widget build(BuildContext context) => Obx(() {
        final selected = controller.selectedRole == label;
        return GestureDetector(
          onTap: () => controller.setRole(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 70.h,
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFFF9A32),
                        primary,
                        const Color(0xFFFF4A16),
                      ],
                    )
                  : null,
              color: selected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: .26),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24.sp,
                  color: selected ? Colors.white : const Color(0xFF4B4B50),
                ),
                SizedBox(height: 5.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : const Color(0xFF3F3F46),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .92),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE1E3E8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .035),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF18181B),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _FooterBenefit extends StatelessWidget {
  const _FooterBenefit({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: const Color(0xFF3F3F46),
          ),
          SizedBox(width: 7.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 7.6.sp,
              height: 1.35,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: const Color(0xFF27272A),
            ),
          ),
        ],
      );
}
