import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/children/edit_profile_screen.dart';
import 'package:pler_to_pler_app/widgets/sliver_scaffold.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerProfileScreen extends StatelessWidget {
  const TrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      safeArea: false,
      expandedHeight: 248.h,
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
    );
  }

  Widget _buildBioCardWidget({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          color: AppColors.textSecondary,
          bottom: 6.h,
        ),
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