import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/helpers/prefs_helper.dart';
import 'package:pler_to_pler_app/features/settings/children/account_details_screen.dart';
import 'package:pler_to_pler_app/features/settings/children/earnings_screen.dart';
import 'package:pler_to_pler_app/features/settings/children/invoices_screen.dart';
import 'package:pler_to_pler_app/features/settings/widgets/confirmation_dialog.dart';
import 'package:pler_to_pler_app/features/common/notification/presentation/screen/notification_screen.dart';
import 'package:pler_to_pler_app/features/authentication/data/data_sources/auth_local_data_source.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/screens/legal_privacy_screen.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/connect_device_screen.dart';
import 'package:pler_to_pler_app/features/user/user_profile/presentation/invoice_screens.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:pler_to_pler_app/routes/app_routes.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';

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
        title: 'You really want to logout',
        confirmLabel: 'Logout',
        onConfirm: () async {
          Get.back();
          try {
            await AuthLocalDataSourceImpl().clearAuthData();
            Get.offAllNamed(AppRoute.loginScreen);
          } catch (_) {
            Get.snackbar(
              'Logout failed',
              'Please try again.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
      ),
    );
  }

  // --- UI Logic: Show Delete Account Dialog ---
  void _showDeleteAccountDialog() {
    Get.dialog(
      ConfirmationDialog(
        icon: Icons.person_off,
        title: 'You really want to delete your account',
        description: 'This action can not be undone and all your data will be wiped. Do you wish to continue?',
        confirmLabel: 'Delete account',
        isDeleteAction: true,
        showCancel: true,
        onConfirm: () async {
          Get.back();
          try {
            final response = await ApiClient.deleteData('/auth/account-delete');
            if (response.statusCode != 200) {
              throw Exception(response.statusText);
            }
            await AuthLocalDataSourceImpl().clearAuthData();
            Get.offAllNamed(AppRoute.loginScreen);
          } catch (_) {
            Get.snackbar(
              'Account not deleted',
              'We could not delete your account. Please try again.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
      ),
    );
  }

  String _role = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((__)async{
      getRole();
    });
  }
  Future<void> getRole()async{
    String? role = await PrefsHelper.getString('role');
    _role = role;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: 'Settings',
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            SizedBox(height: 16.h),

            // --- Account Section ---
            _buildContainerCard(
              label: 'Account',
              children: [
                CustomContainer(
                  color: Colors.black.withOpacity(0.05), // Matches light grey fill
                  width: double.infinity,
                  paddingAll: 14.r,
                  radiusAll: 12.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Email',
                        fontSize: 11.sp,
                        color: Colors.grey,
                        bottom: 4.h,
                      ),
                      CustomText(
                        text: 'Ethancarter77@gmail.com',
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // --- App Section ---
            _buildContainerCard(
              label: 'App',
              children: [
                _buildCardListWidget(
                  label: 'App Preferences',
                  onTap: () => Get.to(() => const AccountDetailsScreen()),
                ),
                _buildCardListWidget(
                  label: 'Language & Region',
                  onTap: () => Get.snackbar(
                    'Language & Region',
                    'The app follows your iPhone language and region settings.',
                    snackPosition: SnackPosition.BOTTOM,
                  ),
                ),
                _buildCardListWidget(
                  label: 'Notifications',
                  onTap: () => Get.to(() => const NotificationsScreen()),
                  isSpacer: false, // Last item in section
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // --- Options Section ---
            _buildContainerCard(
              label: 'Options',
              children: [
                _buildCardListWidget(
                  label: 'Earnings',
                  onTap: () => Get.to(() => const EarningsScreen()),
                ),
                _buildCardListWidget(
                  label: 'Connect Device',
                  onTap: () => Get.to(() => const ConnectDeviceScreen()),
                ),
                _buildCardListWidget(
                  label: 'Invoice',
                  onTap: () => Get.to(() => _role=='Trainer'? const InvoicesScreen(): UserInvoicesScreen()),
                ),
                _buildCardListWidget(
                  label: 'Privacy & Security',
                  onTap: () => Get.to(
                    () => const LegalPrivacyScreen(
                      initialDocument: LegalDocument.privacy,
                    ),
                  ),
                  isSpacer: false,
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // --- About Section ---
            _buildContainerCard(
              label: 'About',
                sublabel: 'App version 4.11 (3027)',
              children: [
                _buildCardListWidget(
                  label: 'Privacy Policy',
                  onTap: () => Get.to(
                    () => const LegalPrivacyScreen(
                      initialDocument: LegalDocument.privacy,
                    ),
                  ),
                ),
                _buildCardListWidget(
                  label: 'Terms of Service',
                  onTap: () => Get.to(
                    () => const LegalPrivacyScreen(
                      initialDocument: LegalDocument.terms,
                    ),
                  ),
                ),
                _buildCardListWidget(
                  label: 'Logout',
                  onTap: _showLogoutDialog, // Triggering the UI dialog
                ),
                _buildCardListWidget(
                  label: 'Delete my account',
                  onTap: _showDeleteAccountDialog, // Triggering the UI dialog
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
              CustomText(text: label, fontWeight: FontWeight.bold, fontSize: 16.sp, bottom: 12.h),
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
      color: Colors.black.withOpacity(0.05), // Uniform light grey background
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
            fontWeight: FontWeight.w600,
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
