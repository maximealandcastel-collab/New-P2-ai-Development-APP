import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/account_details_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/earnings_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/invoices_screen.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/screens/legal_privacy_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/widgets/confirmation_dialog.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  void _showLogoutDialog() {
    Get.dialog(
      ConfirmationDialog(
        icon: Icons.logout,
        title: "You really want to logout",
        confirmLabel: "Logout",
        // Confirming used to just close the dialog — the button did nothing at
        // all. LoginController.logout() was already written and complete
        // (disconnects chat, clears the Hive session, clears admin/affiliate
        // mode and their prefs keys, and navigates to login); it simply was
        // never called from here.
        onConfirm: () {
          Get.back();
          LoginController.to.logout();
        },
      ),
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      ConfirmationDialog(
        icon: Icons.person_off,
        title: "You really want to delete your account",
        description: "Your account will be closed and sign-in disabled. Data is removed or retained according to our Privacy Policy. Deleting your account does not cancel Apple or Google subscriptions; cancel them in your device subscription settings.",
        confirmLabel: "Delete account",
        isDeleteAction: true,
        showCancel: true,
        // Was Get.back() only. The whole chain below already existed —
        // AuthService.deleteAccount -> AuthRepository -> DELETE
        // /api/v1/auth/account-delete, and that route is live on the backend —
        // but LoginController.deleteAccount() short-circuited to logout(), so
        // this button signed the user out and left the account intact.
        //
        // The failure path matters more than usual here: if the delete fails,
        // the user must be told, not quietly signed out believing their data is
        // gone. Apple has also required working account deletion since 2022, so
        // a no-op here is a store-review risk as well as a trust one.
        onConfirm: () async {
          Get.back();
          try {
            await LoginController.to.deleteAccount();
          } catch (e) {
            ToastMessageHelper.show(
              e.toString().replaceFirst('Exception: ', ''),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orange = Theme.of(context).colorScheme.primary;
    final adminHasSwitch = Get.isRegistered<AdminModeService>() &&
        AdminModeService.to.isAdmin;
    return CustomScaffold(
      paddingSide: 18.w,
      appBar: CustomAppBar(title: adminHasSwitch ? '' : 'Settings', toolbarHeight: 56.h),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 10.h, bottom: 24.h),
        child: Column(
          children: [
            _SettingsSection(
              title: 'Account',
              icon: Icons.person_outline_rounded,
              color: orange,
              trailing: TextButton.icon(
                onPressed: () => Get.toNamed(AppRoute.profileInformationScreen),
                icon: Icon(Icons.edit_outlined, size: 14.sp),
                label: Text('Edit', style: TextStyle(fontSize: 11.sp)),
                style: TextButton.styleFrom(
                  foregroundColor: orange,
                  backgroundColor: orange.withValues(alpha: 0.07),
                  minimumSize: Size(58.w, 34.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                ),
              ),
              children: [
                if (Get.isRegistered<ProfileController>())
                  Obx(() {
                    final email = ProfileController.to.userData?.email?.trim();
                    return _SettingsRow(
                      title: 'Email',
                      subtitle: email?.isNotEmpty == true ? email! : 'Email unavailable',
                      icon: Icons.mail_outline_rounded,
                      color: orange,
                      onTap: () => Get.toNamed(AppRoute.profileInformationScreen),
                      emphasizedSubtitle: true,
                    );
                  }),
              ],
            ),
            SizedBox(height: 10.h),
            _SettingsSection(
              title: 'App',
              subtitle: 'Manage your app experience',
              icon: Icons.settings_outlined,
              color: orange,
              children: [
                _SettingsRow(
                  title: 'App Preferences',
                  subtitle: 'Account details and password',
                  icon: Icons.phone_iphone_outlined,
                  color: const Color(0xFF3684CC),
                  onTap: () => Get.to(() => const AccountDetailsScreen()),
                ),
                _SettingsRow(
                  title: 'Language & Region',
                  subtitle: 'Language, country and units',
                  icon: Icons.language_rounded,
                  color: orange,
                  onTap: () => Get.snackbar(
                    'Language & Region',
                    'Language and region settings are not available yet.',
                    snackPosition: SnackPosition.BOTTOM,
                  ),
                ),
                _SettingsRow(
                  title: 'Notifications',
                  subtitle: 'Push, email and in-app alerts',
                  icon: Icons.notifications_none_rounded,
                  color: const Color(0xFF8065C9),
                  onTap: () => Get.toNamed(AppRoute.notificationsScreen),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            _SettingsSection(
              title: 'Options',
              subtitle: 'Manage your account and payments',
              icon: Icons.account_balance_wallet_outlined,
              color: orange,
              children: [
                _SettingsRow(
                  title: 'Earnings',
                  subtitle: 'View your earnings and payout details',
                  icon: Icons.attach_money_rounded,
                  color: const Color(0xFF20A963),
                  onTap: () => Get.to(() => const EarningsScreen()),
                ),
                _SettingsRow(
                  title: 'Invoice',
                  subtitle: 'View and manage your invoices',
                  icon: Icons.receipt_long_outlined,
                  color: orange,
                  onTap: () => Get.to(() => const InvoicesScreen()),
                ),
                _SettingsRow(
                  title: 'Privacy & Security',
                  subtitle: 'Manage your security settings',
                  icon: Icons.shield_outlined,
                  color: const Color(0xFF8065C9),
                  onTap: () => Get.toNamed(AppRoute.changePasswordScreen),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            _SettingsSection(
              title: 'About',
              trailing: Text('App version 5.1 (01)',
                  style: TextStyle(fontSize: 10.sp, color: const Color(0xFF79808B))),
              icon: Icons.info_outline_rounded,
              color: orange,
              children: [
                _SettingsRow(
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  icon: Icons.description_outlined,
                  color: const Color(0xFF3684CC),
                  onTap: () => Get.toNamed(AppRoute.privacyPolicyScreen),
                ),
                _SettingsRow(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  icon: Icons.article_outlined,
                  color: orange,
                  onTap: () => Get.to(() => const LegalPrivacyScreen(
                    initialDocument: LegalDocument.terms,
                  )),
                ),
                _SettingsRow(
                  title: 'Logout',
                  subtitle: 'Sign out from your account',
                  icon: Icons.logout_rounded,
                  color: const Color(0xFFE45252),
                  onTap: _showLogoutDialog,
                ),
                _SettingsRow(
                  title: 'Delete my account',
                  subtitle: 'Permanently delete your account',
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFE45252),
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17.r),
      border: Border.all(color: const Color(0xFFEDEEF1)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(width: 10.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14.sp,
              fontWeight: AppFontWeight.section, color: const Color(0xFF20232B))),
          if (subtitle != null)
            Text(subtitle!, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF777D89))),
        ])),
        if (trailing != null) trailing!,
      ]),
      SizedBox(height: 11.h),
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) SizedBox(height: 7.h),
        children[i],
      ],
    ]),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.emphasizedSubtitle = false,
  });

  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool emphasizedSubtitle;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFF8F9FB),
    borderRadius: BorderRadius.circular(12.r),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 52.h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Row(children: [
            Container(
              width: 30.r, height: 30.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Icon(icon, size: 18.sp, color: color),
            ),
            SizedBox(width: 11.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, fontWeight: AppFontWeight.label,
                      color: const Color(0xFF20232B))),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.sp,
                      fontWeight: emphasizedSubtitle ? AppFontWeight.label : AppFontWeight.body,
                      color: emphasizedSubtitle ? const Color(0xFF20232B) : const Color(0xFF777D89))),
            ])),
            SizedBox(width: 6.w),
            Icon(Icons.chevron_right_rounded, size: 18.sp, color: const Color(0xFF8B919C)),
          ]),
        ),
      ),
    ),
  );
}
