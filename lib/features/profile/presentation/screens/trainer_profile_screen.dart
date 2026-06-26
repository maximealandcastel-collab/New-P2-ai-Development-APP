import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/list_tile_widget.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/profile_flexible_background.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;
    return SliverScaffold(
      appBar: CustomSliverAppBar(
        safeArea: false,
        expandedHeight: 270.h,
        collapsedTitle: controller.userData?.fullName ?? '',
        foregroundColor: Colors.white,
        flexibleBackground: const ProfileFlexibleBackground(),
      ),
      body: CustomScrollView(
        slivers: _buildSlivers(context),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) => [
        SizedBox(height: 20.h).asSliver,
        _buildBioCardWidget(
          fontSize: 12.sp,
          label: 'Bio',
          value:
          'NASM CPT | Functional Strength'
              ' Coach | Precision Nutrition L1. Specializing in physique'
              ' maintenance and sustainable training. NASM CPT | Functional '
              'Strength Coach | Precision Nutrition L1. Specializing in physique '
              'maintenance and sustainable training',
        ).asSliver,

        _buildBioCardWidget(
          label: 'Specialty',
          value: 'Post-Op Recovery',
        ).asSliver,
        _buildBioCardWidget(
          label: 'Certifications',
          value: 'ACE, NASM, PT Licences',
        ).asSliver,
        _buildBioCardWidget(
          label: 'Trainer style tags',
          value: ' PT Licences',
        ).asSliver,

        ContainerCard(label: 'App', children: [
          ListTileWidget(label: 'My prompt', onTap: () {  },),
          ListTileWidget(label: 'Personal information', onTap: () {  },),
          ListTileWidget(label: 'Admin support', onTap: () {  },),
          ListTileWidget(label: 'Settings', onTap: () {
            Get.toNamed(AppRoute.settingsScreen);
          },),
        ],

        ).asSliverWithPadding(horizontal: 16.w),
      ];

  Widget _buildBioCardWidget({
    required String label,
    required String value,
    double? fontSize,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: label, color: AppColors.textSecondary, bottom: 6.h),
          CustomText(
            textAlign: TextAlign.start,
            text: value,
            fontSize: fontSize ?? 16.sp,
            fontWeight: FontWeight.w500,
            bottom: 10.h,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityDay(String day, bool isAvailable) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomContainer(
          width: 40.r,
          height: 40.r,
          shape: BoxShape.circle,
          color: isAvailable ? Colors.black : Colors.transparent,
          bordersColor: isAvailable ? Colors.black : Colors.grey.shade300,
          child: Center(
            child: CustomText(
              text: day,
              color: isAvailable ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CustomContainer(
          marginTop: 4.h,
          height: 4.h,
          width: 43.w,
          color: isAvailable ? Colors.green : Colors.black.withValues(alpha: 0.12),
        ),
      ],
    );
  }
}