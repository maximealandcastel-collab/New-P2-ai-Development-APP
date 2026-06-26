import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/profile_fixed_account_card.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/profile_info_section_card.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileInformationScreen extends StatelessWidget {
  const ProfileInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = ProfileController.to.userData;
      final personalRows = StringFormat.buildPersonalProfileRows(user);
      final fitnessRows = StringFormat.buildFitnessProfileRows(user);
      final hasAccountInfo = StringFormat.hasAccountInfo(user);

      return SliverScaffold(
        appBar: CustomSliverAppBar(
          title: 'Profile Information',
        ),
        bodyList: [
          SizedBox(height: 16.h).asSliver,
          if (hasAccountInfo) ...[
            ProfileFixedAccountCard(
              email: user?.email ?? '',
              username: user?.preferredName,
            ).asSliverWithPadding(horizontal: 16.w),
            SizedBox(height: 12.h).asSliver,
          ],
          ProfileInfoSectionCard(
            title: 'Personal details',
            onEdit: () => Get.toNamed(AppRoute.editPersonalInfoScreen),
            rows: personalRows,
          ).asSliverWithPadding(horizontal: 16.w),
          SizedBox(height: 12.h).asSliver,
          ProfileInfoSectionCard(
            title: 'Fitness profile',
            onEdit: () => Get.toNamed(AppRoute.editFitnessInfoScreen),
            rows: fitnessRows,
          ).asSliverWithPadding(horizontal: 16.w),
          SizedBox(height: 12.h).asSliver,


          CustomContainer(
            radiusAll: 20.r,
            paddingAll: 16.r,
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Security',
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  bottom: 12.h,
                ),
                CustomContainer(
                  onTap: () => Get.toNamed(AppRoute.changePasswordScreen),
                  color: Colors.black.withValues(alpha: 0.05),
                  width: double.infinity,
                  paddingHorizontal: 16.w,
                  paddingVertical: 14.h,
                  radiusAll: 12.r,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Password',
                              fontSize: 12.sp,
                              color: Colors.grey,
                              bottom: 4.h,
                            ),
                            CustomText(
                              text: '••••••••',
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14.sp,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).asSliverWithPadding(horizontal: 16.w),
          SizedBox(height: 100.h).asSliver,
        ],
      );
    });
  }
}
