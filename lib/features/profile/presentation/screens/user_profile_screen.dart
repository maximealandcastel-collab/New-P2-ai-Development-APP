import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/list_tile_widget.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/screens/privacy_policy_all_screen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/profile_flexible_background.dart';
import 'package:pler_to_pler_app/features/settings/widgets/confirmation_dialog.dart';
import 'package:pler_to_pler_app/features/user/connect_device/presentation/manage_devices_screen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return SliverScaffold(
      floating: false,
      safeArea: false,
      expandedHeight: 270.h,
      collapsedTitle: controller.userData?.fullName ?? '',
      appBarForegroundColor: Colors.white,
      flexibleBackground: const ProfileFlexibleBackground(
        showEditProfileButton: true,
      ),

      slivers: _buildSlivers,
    );
  }

  List<Widget> _buildSlivers(BuildContext context) => [
    SizedBox(height: 20.h).asSliver,

    ContainerCard(
      label: 'Account Management',
      children: [
        ListTileWidget(label: 'Profile Information', onTap: () {}),
        ListTileWidget(
          label: 'Change Password',
          onTap: () => Get.toNamed(AppRoute.changePasswordScreen),
        ),
        ListTileWidget(
          label: 'Manage devices',
          onTap: () => Get.to(() => const ManageDevicesScreen()),
        ),
      ],
    ).asSliverWithPadding(horizontal: 16.w),

    SizedBox(height: 12.h).asSliver,

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
  ];
}
