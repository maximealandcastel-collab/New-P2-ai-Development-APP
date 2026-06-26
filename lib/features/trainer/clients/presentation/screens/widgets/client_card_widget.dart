import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ClientCardWidget extends StatelessWidget {
  const ClientCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginTop: 8.h,
      radiusAll: 12.r,
      color: Colors.white,
      paddingHorizontal: 12.w,
      paddingVertical: 6.h,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CustomNetworkImage(
          height: 40.r,
          width: 40.r,
          boxShape: BoxShape.circle,
          border: Border.all(color: Colors.black.withValues(alpha: 0.48)),
          imageUrl: '',
        ),
        title: CustomText(
          textAlign: TextAlign.start,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          text: 'John Adams',
        ),
        subtitle: CustomText(
          textAlign: TextAlign.start,
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          text: 'Subscription period\n12 January 2026 - 12 February 2026',
        ),
        trailing: GestureDetector(
          onTap: (){
            Get.toNamed(AppRoute.chatScreen);
          },
          behavior: HitTestBehavior.opaque,
            child: Assets.icons.message.svg()),
      ),
    );
  }
}
