import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/list_tile_widget.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/profile_flexible_background.dart';
import 'package:pler_to_pler_app/features/settings/presentation/widgets/confirmation_dialog.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return SliverScaffold(
      appBar: CustomSliverAppBar(
        safeArea: false,
        expandedHeight: 270.h,
        collapsedTitle: controller.userData?.fullName ?? '',
        foregroundColor: Colors.black,
        flexibleBackground: const ProfileFlexibleBackground(),
      ),
      bodyList: [
        SizedBox(height: 20.h).asSliver,

        ContainerCard(
          label: 'Account Management',
          children: [
            ListTileWidget(
              label: 'Profile Information',
              onTap: () => Get.toNamed(AppRoute.profileInformationScreen),
            ),
            ListTileWidget(
              label: 'Change Password',
              onTap: () => Get.toNamed(AppRoute.changePasswordScreen),
            ),
            ListTileWidget(
              label: 'Manage devices',
              onTap: () => Get.toNamed(AppRoute.manageDevicesScreen),
            ),
            ListTileWidget(
              label: 'Post Before & After',
              onTap: () => Get.toNamed(AppRoute.beforeAfterScreen),
            ),
          ],
        ).asSliverWithPadding(horizontal: 16.w),

        SizedBox(height: 12.h).asSliver,

        ContainerCard(
          label: 'About',
          sublabel: 'P2P FitTech AI',
          children: [
            ListTileWidget(
              label: 'Privacy Policy',
              onTap: () => Get.toNamed(
                AppRoute.privacyPolicyScreen,
                arguments: {'title': 'Privacy Policy', 'key': 'privacy'},
              ),
            ),
            ListTileWidget(
              label: 'Terms of Service',
              onTap: () => Get.toNamed(
                AppRoute.privacyPolicyScreen,
                arguments: {'title': 'Terms of Service', 'key': 'terms'},
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
              },
            ),
            ListTileWidget(
              label: 'Delete my account',
              onTap: () {
                Get.dialog(
                  ConfirmationDialog(
                    icon: Icons.person_off,
                    title: 'Delete your account?',
                    description:
                        'Your account will be closed and sign-in disabled. Data is removed or retained according to our Privacy Policy. Deleting your account does not cancel Apple or Google subscriptions; cancel them in your device subscription settings.',
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
      ],
    );
  }
}
