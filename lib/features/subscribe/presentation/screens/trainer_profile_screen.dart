import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerProfileScreen extends StatelessWidget {
  const TrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      safeArea: false,
      expandedHeight: 270.h,
      collapsedTitle: 'Noah Sinclair',
      appBarForegroundColor: Colors.white,
      flexibleBackground: CustomContainer(
        child: Stack(
          children: [
            CustomNetworkImage(
              height: 210.h,
              fit: BoxFit.cover,
              width: double.infinity,
              imageUrl: "https://picsum.photos/300",
            ),
            Positioned(
              top: 132.h,
              left: 16.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomContainer(
                    shape: BoxShape.circle,
                    paddingAll: 6.r,
                    bordersColor: AppColors.primary,
                    child: CustomNetworkImage(
                      height: 124.r,
                      width: 124.r,
                      boxShape: BoxShape.circle,
                      imageUrl: "https://picsum.photos/300",
                    ),
                  ),
                  CustomText(
                    top: 6.h,
                    text: 'Noah Sinclair',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      slivers: (context) => [
        SizedBox(height: 20.h).asSliver,
        CustomButton(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          onPressed: () {},
          label: 'Already subscribed 23',
          prefixIcon: Assets.icons.subButton.svg(),
        ).asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 16.h).asSliver,
        CustomButton(
          onPressed: () {},
          label: 'Request trainer',
        ).asSliverWithPadding(horizontal: 16.w),

        SizedBox(height: 24.h).asSliver,

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

        CustomContainer(
          horizontalMargin: 16.h,
          verticalMargin: 24.h,
          paddingAll: 20.r,
          radiusAll: 20.r,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                top: 10.h,
                bottom: 4.h,
                text: 'monthly',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              CustomText(
                bottom: 16.h,
                text: '\$ 12.99',
                fontSize: 36.sp,
                fontWeight: FontWeight.w800,
              ),
              Assets.icons.trainerSubIcons.svg(),

              SizedBox(height: 16.h),
              ...HelperData.trainerGuidance.map((e) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    children: [
                      Icon(Icons.lock_rounded, size: 16.r),
                      SizedBox(width: 6.w),
                      CustomText(
                        text: e,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ).asSliver,

        SizedBox(height: 60.h).asSliver,
      ],
    );
  }

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
