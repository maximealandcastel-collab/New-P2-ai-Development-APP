import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/list_tile_widget.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/profile_flexible_background.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/trainer_profile_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;

    return Obx(() {
      final isLoading = controller.loadingState.isLoading;
      final trainer = controller.trainerData;

      return SliverScaffold(
        appBar: CustomSliverAppBar(
          safeArea: false,
          expandedHeight: 270.h,
          collapsedTitle: isLoading ? '' : trainer?.name ?? controller.userData?.fullName ?? '',
          foregroundColor: Colors.white,
          flexibleBackground: isLoading
              ? TrainerProfileShimmer.headerShimmer()
              : const ProfileFlexibleBackground(),
        ),
        bodyList: isLoading
            ? TrainerProfileShimmer.contentSlivers()
            : _buildSlivers(context, trainer),
      );
    });
  }

  List<Widget> _buildSlivers(
    BuildContext context,
    TrainerDetailsModel? trainer,
  ) => [
        SizedBox(height: 20.h).asSliver,
        _buildBioCardWidget(
          fontSize: 12.sp,
          label: 'Bio',
          value: StringFormat.valueOrNa(trainer?.bio),
        ).asSliver,
        _buildBioCardWidget(
          label: 'Specialty',
          value: StringFormat.specialtyOrNa(trainer?.specialty),
        ).asSliver,
        _buildBioCardWidget(
          label: 'Certifications',
          value: StringFormat.listOrNa(trainer?.certifications),
        ).asSliver,
        _buildBioCardWidget(
          label: 'Trainer style tags',
          value: StringFormat.listOrNa(trainer?.trainingStyleTags),
        ).asSliver,
        ContainerCard(
          label: 'App',
          children: [
            ListTileWidget(label: 'My prompt', onTap: () {}),
            ListTileWidget(label: 'Personal information', onTap: () {}),
            ListTileWidget(label: 'Admin support', onTap: () {}),
            ListTileWidget(
              label: 'Settings',
              onTap: () => Get.toNamed(AppRoute.settingsScreen),
            ),
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
}
