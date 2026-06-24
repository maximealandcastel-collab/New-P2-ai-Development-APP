import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/list_tile_widget.dart';
import 'package:pler_to_pler_app/features/settings/children/account_details_screen.dart';
import 'package:pler_to_pler_app/features/settings/children/earnings_screen.dart';
import 'package:pler_to_pler_app/features/settings/children/invoices_screen.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/screens/privacy_policy_all_screen.dart';
import 'package:pler_to_pler_app/features/settings/widgets/confirmation_dialog.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/connect_device_screen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBarTitle: 'Settings',
      slivers: _buildSlivers,
    );
  }

  List<Widget> _buildSlivers(BuildContext context) => [
        SizedBox(height: 16.h).asSliver,
          ContainerCard(
            label: 'Account',
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
          ).asSliverWithPadding(horizontal: 16.w),

          SizedBox(height: 12.h).asSliver,

          // --- App Section ---
          ContainerCard(
            label: 'App',
            children: [
              ListTileWidget(
                label: 'App Preferences',
                onTap: () => Get.to(() => const AccountDetailsScreen()),
              ),
              ListTileWidget(label: 'Language & Region', onTap: () {}),
              ListTileWidget(
                label: 'Notifications',
                onTap: () {},
                isSpacer: false,
              ),
            ],
          ).asSliverWithPadding(horizontal: 16.w),

          SizedBox(height: 12.h).asSliver,

          // --- Options Section ---
          ContainerCard(
            label: 'Options',
            children: [
              ListTileWidget(
                label: 'Earnings',
                onTap: () => Get.to(() => const EarningsScreen()),
              ),
              ListTileWidget(
                label: 'Connect Device',
                onTap: () => Get.to(() => const ConnectDeviceScreen()),
              ),
              ListTileWidget(
                label: 'Invoice',
                onTap: () => Get.to(() => const InvoicesScreen()),
              ),
              ListTileWidget(
                label: 'Privacy & Security',
                onTap: () {},
                isSpacer: false,
              ),
            ],
          ).asSliverWithPadding(horizontal: 16.w),

          SizedBox(height: 12.h).asSliver,

          // --- About Section ---
          ContainerCard(
            label: 'About',
            sublabel: 'App version 1.58.7.1',
            children: [
              ListTileWidget(
                label: 'Privacy Policy',
                onTap: () => Get.to(
                  () => const PrivacyPolicyAllScreen(),
                  arguments: {
                    'title': 'Privacy Policy',
                    'key': 'privacy',
                  },
                ),
              ),
              ListTileWidget(
                label: 'Terms of Service',
                onTap: () => Get.to(
                  () => const PrivacyPolicyAllScreen(),
                  arguments: {
                    'title': 'Terms of Service',
                    'key': 'terms',
                  },
                ),
              ),
              ListTileWidget(
                label: 'Logout',
                onTap: () {
                  Get.dialog(
                    ConfirmationDialog(
                      icon: Icons.logout,
                      title: 'You really want to logout',
                      confirmLabel: 'Logout',
                      onConfirm: LoginController.to.logout,
                    ),
                  );
                }, // Triggering the UI dialog
              ),
              ListTileWidget(
                label: 'Delete my account',
                onTap: () {
                  Get.dialog(
                    ConfirmationDialog(
                      icon: Icons.person_off,
                      title: 'Delete your account?',
                      description:
                          'This action can not be undone and all your data will be wiped. Do you wish to continue?',
                      confirmLabel: 'Delete account',
                      isDeleteAction: true,
                      showCancel: true,
                      onConfirm: LoginController.to.deleteAccount,
                    ),
                  );
                },
                isSpacer: false,
                textColor: Colors.redAccent,
              ),
            ],
          ).asSliverWithPadding(horizontal: 16.w),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h).asSliver,
      ];
}
