import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RequestProfileHeader extends StatelessWidget {
  const RequestProfileHeader({super.key, required this.request});

  final TrainerRequestModel request;

  @override
  Widget build(BuildContext context) {
    final user = request.userId;
    final coverPhoto = user?.coverPhoto ?? user?.profilePicture ?? '';

    return CustomContainer(
      child: Stack(
        children: [
          CustomNetworkImage(
            height: 210.h,
            fit: BoxFit.cover,
            width: double.infinity,
            imageUrl: coverPhoto,
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
                    imageUrl: user?.profilePicture ?? '',
                  ),
                ),
                CustomText(
                  top: 6.h,
                  text: request.clientName,
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
