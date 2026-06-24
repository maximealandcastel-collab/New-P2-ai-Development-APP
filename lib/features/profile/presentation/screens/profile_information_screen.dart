import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/profile/data/models/user_model.dart';
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

      final personalRows = [
        (
          label: 'First name',
          value: StringFormat.valueOrNa(user?.firstName),
        ),
        (
          label: 'Last name',
          value: StringFormat.valueOrNa(user?.lastName),
        ),
        (
          label: 'Preferred name',
          value: StringFormat.valueOrNa(user?.preferredName),
        ),
        (
          label: 'Gender',
          value: StringFormat.valueOrNa(
            MenuShowHelper.genderDisplayValue(user?.gender),
          ),
        ),
        (
          label: 'Date of birth',
          value: _formatDateOfBirth(user),
        ),
      ];

      final fitnessRows = [
        (
          label: 'Primary goal',
          value: StringFormat.valueOrNa(
            MenuShowHelper.goalDisplayValue(user?.primaryGoal),
          ),
        ),
        (
          label: 'Height',
          value: StringFormat.valueOrNa(
            MenuShowHelper.heightDisplayValue(user?.height),
          ),
        ),
        (
          label: 'Weight',
          value: StringFormat.valueOrNa(
            MenuShowHelper.weightDisplayValue(user?.weight),
          ),
        ),
        (
          label: 'Fitness level',
          value: StringFormat.valueOrNa(
            MenuShowHelper.fitnessLevelDisplayValue(user?.fitnessLevel),
          ),
        ),
        (
          label: 'Available equipment',
          value: StringFormat.valueOrNa(
            MenuShowHelper.equipmentDisplayValue(user?.availableEquipment),
          ),
        ),
        (
          label: 'Training days per week',
          value: user?.trainingDaysPerWeek?.toString() ?? 'N/A',
        ),
        (
          label: 'Injuries',
          value: StringFormat.listOrNa(user?.injuries),
        ),
        (
          label: 'Motivation style',
          value: StringFormat.valueOrNa(
            MenuShowHelper.motivationStyleDisplayValue(user?.motivationStyle),
          ),
        ),
      ];

      return SliverScaffold(
        floating: false,
        appBarTitle: 'Profile Information',
        slivers: (context) => [
          SizedBox(height: 16.h).asSliver,
          ProfileFixedAccountCard(
            email: user?.email ?? '',
            role: MenuShowHelper.roleDisplayValue(user?.role),
          ).asSliverWithPadding(horizontal: 16.w),
          SizedBox(height: 12.h).asSliver,
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
          SizedBox(height: 24.h).asSliver,
        ],
      );
    });
  }

  String _formatDateOfBirth(UserModel? user) {
    final dateOfBirth = user?.dateOfBirth;
    if (dateOfBirth == null || dateOfBirth.isEmpty) return 'N/A';
    return TimeFormatHelper.formatDate(DateTime.parse(dateOfBirth));
  }
}
