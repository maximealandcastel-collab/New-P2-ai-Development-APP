import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/photo_picker_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileFlexibleBackground extends StatelessWidget {
  const ProfileFlexibleBackground({
    super.key,
    this.showEditProfileButton = false,
    this.onEditProfileTap,
  });

  final bool showEditProfileButton;
  final VoidCallback? onEditProfileTap;

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;

    return CustomContainer(
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
                  imageFile: controller.selectedCoverPhoto,
                  imageUrl: user?.coverPhoto,
                ),
                Positioned(
                  bottom: 12.h,
                  right: 16.w,
                  child: CustomContainer(
                    onTap: () {
                      PhotoPickerHelper.showPicker(
                        context: context,
                        onImagePicked: (image) {
                          controller.uploadCoverPhoto(File(image.path));
                        },
                      );
                    },
                    radiusAll: 12.r,
                    paddingVertical: 4.h,
                    paddingHorizontal: 14.r,
                    color: AppColors.textWhite.withValues(alpha: 0.8),
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 14.r, color: Colors.black),
                        CustomText(
                          text: 'Change Cover',
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          left: 4.w,
                        ),
                      ],
                    ),
                  ),
                ),
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
                          imageFile: controller.selectedProfilePicture,
                          imageUrl: user?.profilePicture,
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 2,
                        child: CustomContainer(
                          onTap: () {
                            PhotoPickerHelper.showPicker(
                              context: context,
                              onImagePicked: (image) {
                                controller.uploadProfilePicture(
                                  File(image.path),
                                );
                              },
                            );
                          },
                          shape: BoxShape.circle,
                          paddingAll: 8.r,
                          color: AppColors.primary.withValues(alpha: 0.8),
                          child: Icon(
                            Icons.edit,
                            size: 14.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
            if (showEditProfileButton)
              Positioned(
                bottom: 44.h,
                right: 16.w,
                child: CustomContainer(
                  onTap: onEditProfileTap,
                  radiusAll: 12.r,
                  paddingVertical: 6.h,
                  paddingHorizontal: 14.r,
                  color: AppColors.textWhite.withValues(alpha: 0.8),
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 14.r, color: Colors.black),
                      CustomText(
                        text: 'Edit Profile',
                        color: Colors.black,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        left: 4.w,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
