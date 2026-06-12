import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerProfileScreen extends StatelessWidget {
  const TrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      safeArea: false,
      expandedHeight: 258.h,
      appBarTitle: 'Profile',
      appBarForegroundColor: Colors.white,
      flexibleBackground: CustomContainer(
        child: Stack(
          children: [
            CustomNetworkImage(
              height: 221.h,
              fit: BoxFit.cover,
              width: double.infinity,
              imageUrl: "https://picsum.photos/300",
            ),
            Positioned(
              top: 142.h,
              left: 16.w,
              child: CustomContainer(
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
            ),
          ],
        ),
      ),

      slivers: (context) => [
        CustomText(
          text: 'Noah Sinclair',
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.start,
        ).asSliverWithPadding(horizontal: 16.w),

        SizedBox(height: 24.h).asSliver,
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
      ],
    );
  }

  Widget _buildBioCardWidget({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: label, color: AppColors.textSecondary, bottom: 6.h),
        CustomText(
          text: value,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          maxline: 1,
          textOverflow: TextOverflow.ellipsis,
          bottom: 10.h,
        ),
      ],
    );
  }
}
