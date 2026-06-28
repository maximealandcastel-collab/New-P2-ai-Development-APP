import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerProfileHeader extends StatelessWidget {
  const TrainerProfileHeader({
    super.key,
    required this.name,
    this.coverPhoto,
    this.profilePicture,
  });

  final String name;
  final String? coverPhoto;
  final String? profilePicture;

  @override
  Widget build(BuildContext context) {
    final cover = coverPhoto ?? profilePicture ?? '';

    return CustomContainer(
      child: Stack(
        children: [
          CustomNetworkImage(
            height: 210.h,
            fit: BoxFit.cover,
            width: double.infinity,
            imageUrl: cover,
          ),
          Positioned(
            top: 132.h,
            left: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    imageUrl: profilePicture ?? '',
                  ),
                ),
                CustomText(
                  top: 6.h,
                  text: name,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
