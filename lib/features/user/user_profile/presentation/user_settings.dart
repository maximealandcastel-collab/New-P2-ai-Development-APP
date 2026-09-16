import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/screens/legal_privacy_screen.dart';
import 'package:pler_to_pler_app/features/user/user_profile/presentation/invoice_screens.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 2 — SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════

class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  static const _appItems = ['App Preferences', 'Language & Region', 'Notifications'];
  static const _optionItems = ['Payment options', 'Invoices', 'P2Bot Settings'];
  static const _legalItems = ['Privacy Policy', 'Terms of Service'];
  static const _aboutItems = ['Logout'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 34.w, height: 34.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Icon(Icons.chevron_left, size: 20.sp, color: Colors.black87),
                    ),
                  ),
                  Expanded(
                    child: Text('Settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                  ),
                  SizedBox(width: 34.w),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account section
                    _SectionLabel('Account'),
                    SizedBox(height: 8.h),
                    _SettingsCard(
                      children: [
                        _EmailTile(email: 'Ethancarter77@gmail.com'),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // App section
                    _SectionLabel('App'),
                    SizedBox(height: 8.h),
                    _SettingsCard(
                      children: _appItems
                          .asMap()
                          .entries
                          .map((e) => _SettingsTile(
                        label: e.value,
                        showDivider: e.key < _appItems.length - 1,
                        onTap: () => _showUnavailableMessage(
                          context,
                          '${e.value} is not available yet.',
                        ),
                      ))
                          .toList(),
                    ),
                    SizedBox(height: 20.h),

                    // Options section
                    _SectionLabel('Options'),
                    SizedBox(height: 8.h),
                    _SettingsCard(
                      children: _optionItems
                          .asMap()
                          .entries
                          .map((e) => _SettingsTile(
                        label: e.value,
                        showDivider: e.key < _optionItems.length - 1,
                        onTap: () {
                          if (e.value == 'Invoices') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserInvoicesScreen(),
                              ),
                            );
                            return;
                          }
                          _showUnavailableMessage(
                            context,
                            '${e.value} is not available yet.',
                          );
                        },
                      ))
                          .toList(),
                    ),
                    SizedBox(height: 20.h),

                    // About section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionLabel('About'),
                        Text('P2P FitTech AI',
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          label: 'Privacy Policy',
                          showDivider: true,
                          onTap: () => Get.to(() => const LegalPrivacyScreen()),
                        ),
                        _SettingsTile(
                          label: 'Terms of Service',
                          showDivider: true,
                          onTap: () => Get.to(() => const LegalPrivacyScreen()),
                        ),
                        ..._aboutItems
                            .asMap()
                            .entries
                            .map((e) => _SettingsTile(
                          label: e.value,
                          showDivider: true,
                          onTap: () => LoginController.to.logout(),
                        )),
                        _SettingsTile(
                          label: 'Delete my account',
                          showDivider: false,
                          labelColor: const Color(0xFFE53935),
                           onTap: () => _showUnavailableMessage(
                             context,
                             'Account deletion is not available from this screen yet.',
                           ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showUnavailableMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black),
  );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}

class _EmailTile extends StatelessWidget {
  final String email;

  const _EmailTile({required this.email});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
          SizedBox(height: 4.h),
          Text(email,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final bool showDivider;
  final Color? labelColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.label,
    required this.showDivider,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: labelColor ?? Colors.black87,
                    )),
                Icon(Icons.chevron_right, size: 18.sp, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 14.w, endIndent: 14.w, color: Colors.grey.shade100),
      ],
    );
  }
}
