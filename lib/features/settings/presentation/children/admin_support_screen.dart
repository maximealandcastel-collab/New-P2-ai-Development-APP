import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AdminSupportScreen extends StatelessWidget {
  const AdminSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: CustomSliverAppBar(title: 'Admin Support'),
      bodyList: [
        SizedBox(height: 60.h).asSliver,
        Assets.images.support
            .image(width: 227.w, height: 263.h, fit: BoxFit.contain)
            .asSliverWithPadding(horizontal: 16.w),
        CustomText(
          top: 32.h,
          fontSize: 22.sp,
          color: AppColors.textSecondary,
          text:
              'If you face any kind of problem with ur service feel free to contact us.',
        ).asSliverWithPadding(horizontal: 16.w),
        CustomContainer(
          paddingVertical: 4.h,
          paddingHorizontal: 8.r,
          radiusAll: 50.r,
          bordersColor: AppColors.yellow,
          color: AppColors.textSecondary,
          child: Row(
            children: [
              Assets.icons.supprtMail.svg(),
              SizedBox(width: 12.w),
              CustomText(
                fontSize: 16.sp,
                color: AppColors.textWhite,
                text: 'support@pler.com',
              ),
            ],
          ),
        ).asSliverWithPadding(horizontal: 16.w, vertical: 32.h),
      ],
    );
  }
}
