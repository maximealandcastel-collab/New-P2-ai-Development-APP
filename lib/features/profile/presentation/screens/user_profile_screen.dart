import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/list_tile_widget.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/screens/privacy_policy_all_screen.dart';
import 'package:pler_to_pler_app/features/settings/widgets/confirmation_dialog.dart';
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
      flexibleBackground: CustomContainer(
        child: Obx(() {
          final user = controller.userData;
          return Stack(
            children: [
              Stack(
                children: [
                  CustomNetworkImage(
                    height: 210.h,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    imageUrl: controller.userData?.coverPhoto,
                  ),
                  Positioned(
                      bottom: 12.h,
                      right: 16.w,
                      child: CustomContainer(
                        radiusAll: 12.r,
                          paddingVertical: 4.h,
                          paddingHorizontal: 14.r,
                          color: AppColors.textWhite.withValues(alpha: 0.8),
                          child: Row(
                            children: [
                              Icon(Icons.edit,size: 14.r,color: Colors.black),
                              CustomText(text: 'Change Cover',color: Colors.black,fontSize: 12.sp,fontWeight: FontWeight.w600,left: 4.w),
                            ],
                          ))),
                ],
              ),
              Positioned(
                top: 132.h,
                left: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        CustomContainer(
                          shape: BoxShape.circle,
                          paddingAll: 6.r,
                          bordersColor: AppColors.primary,
                          child: CustomNetworkImage(
                            height: 124.r,
                            width: 124.r,
                            boxShape: BoxShape.circle,
                            imageUrl: controller.userData?.profilePicture,
                          ),
                        ),
                        
                        Positioned(
                          bottom: 12,
                            right: 2,
                            child: CustomContainer(
                          shape: BoxShape.circle,
                            paddingAll: 8.r,
                            color: AppColors.primary.withValues(alpha: 0.8),
                            child: Icon(Icons.edit,size: 14.r,color: Colors.white))),
                      ],
                    ),
                    CustomText(
                      top: 6.h,
                      text: user?.fullName ?? '',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),

              Positioned(
                  bottom: 44.h,
                  right: 16.w,
                  child: CustomContainer(
                      radiusAll: 12.r,
                      paddingVertical: 6.h,
                      paddingHorizontal: 14.r,
                      color: AppColors.textWhite.withValues(alpha: 0.8),
                      child: Row(
                        children: [
                          Icon(Icons.edit,size: 14.r,color: Colors.black),
                          CustomText(text: 'Edit Profile',color: Colors.black,fontSize: 12.sp,fontWeight: FontWeight.w600,left: 4.w),
                        ],
                      ))),
            ],
          );
        }),
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
        ListTileWidget(label: 'Notifications', onTap: () {}),
        ListTileWidget(label: 'Change Password', onTap: () {}),
        ListTileWidget(
          label: 'Manage devices',
          onTap: () {
            Get.toNamed(AppRoute.settingsScreen);
          },
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
