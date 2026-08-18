import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/list_tile_widget.dart';
import 'package:pler_to_pler_app/features/settings/presentation/widgets/confirmation_dialog.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: CustomSliverAppBar(
        title: 'Settings',
      ),
      bodyList: _buildSlivers(context),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) => [
        SizedBox(height: 16.h).asSliver,
          ContainerCard(
            label: 'Device',
            children: [
              ListTileWidget(
                label: 'Connect Device',
                onTap: () => Get.toNamed(AppRoute.manageDevicesScreen),
              ),
            ],
          ).asSliverWithPadding(horizontal: 16.w),

          SizedBox(height: 12.h).asSliver,

          // --- App Section ---
          ContainerCard(
            label: 'Options',
            children: [
              ListTileWidget(
                label: 'Earnings',
                onTap: () => Get.toNamed(AppRoute.earningsScreen),
              ),
              ListTileWidget(
                label: 'Invoices',
                onTap: () => Get.toNamed(AppRoute.invoicesScreen),
              ),
              if (LoginController.to.isTrainer())
                ListTileWidget(
                  label: 'AI video chat',
                  onTap: () {
                    Get.toNamed(AppRoute.aiVideoChatConnectScreen);
                  },
                  isSpacer: false,
                ),
              if (LoginController.to.isTrainer())
                Obx(() {
                  final active   = Get.isRegistered<AdminModeService>();
                  final viewUser = active && AdminModeService.to.viewAsUser;
                  return ListTileWidget(
                    label: viewUser ? 'Switch to Trainer View' : 'Preview as User',
                    onTap: () async {
                      if (!Get.isRegistered<AdminModeService>()) {
                        Get.put(AdminModeService(), permanent: true);
                        await AdminModeService.to.activate();
                      } else {
                        AdminModeService.to.toggleView();
                      }
                    },
                    isSpacer: false,
                  );
                }),
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
                onTap: () => Get.toNamed(
                  AppRoute.privacyPolicyScreen,
                  arguments: {
                    'title': 'Privacy Policy',
                    'key': 'privacy',
                  },
                ),
              ),
              ListTileWidget(
                label: 'Terms of Service',
                onTap: () => Get.toNamed(
                  AppRoute.privacyPolicyScreen,
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
