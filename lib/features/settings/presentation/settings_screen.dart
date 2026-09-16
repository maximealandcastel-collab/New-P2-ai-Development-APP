import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/helpers/prefs_helper.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/account_details_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/earnings_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/invoices_screen.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
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

  String _role = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((__) async {
      getRole();
    });
  }

  Future<void> getRole() async {
    String? role = await PrefsHelper.getString("role");
    _role = role ?? "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: "Settings",
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildContainerCard(
              label: "Account",
              children: [
                CustomContainer(
                  color: Colors.black.withOpacity(0.05),
                  width: double.infinity,
                  paddingAll: 14.r,
                  radiusAll: 12.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Email",
                        fontSize: 11.sp,
                        color: Colors.grey,
                        bottom: 4.h,
                      ),
                      CustomText(
                        text: "Ethancarter77@gmail.com",
                        fontWeight: AppFontWeight.emphasis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildContainerCard(
              label: "App",
              children: [
                _buildCardListWidget(
                  label: "App Preferences",
                  onTap: () => Get.to(() => const AccountDetailsScreen()),
                ),
                _buildCardListWidget(
                  label: "Language & Region",
                  onTap: () => Get.snackbar(
                    'Language & Region',
                    'Language and region settings are not available yet.',
                    snackPosition: SnackPosition.BOTTOM,
                  ),
                ),
                _buildCardListWidget(
                  label: "Notifications",
                  onTap: () => Get.toNamed(AppRoute.notificationsScreen),
                  isSpacer: false,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildContainerCard(
              label: "Options",
              children: [
                _buildCardListWidget(
                  label: "Earnings",
                  onTap: () => Get.to(() => const EarningsScreen()),
                ),
                _buildCardListWidget(
                  label: "Invoice",
                  onTap: () => Get.to(() => const InvoicesScreen()),
                ),
                _buildCardListWidget(
                  label: "Privacy & Security",
                  onTap: () => Get.toNamed(AppRoute.changePasswordScreen),
                  isSpacer: false,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildContainerCard(
              label: "About",
              sublabel: "App version 4.11.0 (3029)",
              children: [
                _buildCardListWidget(
                  label: "Privacy Policy",
                  onTap: () => Get.toNamed(AppRoute.privacyPolicyScreen),
                ),
                _buildCardListWidget(
                  label: "Terms of Service",
                  onTap: () => Get.toNamed(AppRoute.privacyPolicyScreen),
                ),
                _buildCardListWidget(
                  label: "Logout",
                  onTap: _showLogoutDialog,
                ),
                _buildCardListWidget(
                  label: "Delete my account",
                  onTap: _showDeleteAccountDialog,
                  isSpacer: false,
                  textColor: Colors.redAccent,
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerCard({
    required String label,
    String? sublabel,
    required List<Widget> children,
  }) {
    return CustomContainer(
      radiusAll: 20.r,
      paddingAll: 16.r,
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(text: label, fontWeight: AppFontWeight.section, fontSize: 16.sp, bottom: 12.h),
              if (sublabel != null)
                CustomText(text: sublabel, fontSize: 11.sp, bottom: 12.h, color: Colors.grey),
            ],
          ),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildCardListWidget({
    required String label,
    required VoidCallback onTap,
    Color? textColor,
    bool isSpacer = true,
  }) {
    return CustomContainer(
      onTap: onTap,
      marginBottom: isSpacer ? 8.h : 0,
      color: Colors.black.withOpacity(0.05),
      width: double.infinity,
      paddingHorizontal: 16.w,
      paddingVertical: 14.h,
      radiusAll: 12.r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            fontSize: 15.sp,
            fontWeight: AppFontWeight.label,
            color: textColor ?? Colors.black,
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
