import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/features/settings/children/invoice_preview_screen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class InvoiceCardWidget extends StatelessWidget {
  const InvoiceCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: (){
        Get.to(() => InvoicePreviewScreen());
      },
      marginTop: 8.h,
      radiusAll: 16.r,
      color: Colors.white,
      paddingHorizontal: 12.w,
      child: Column(
        children: [
          ListTile(
            leading: CustomImageAvatar(
              image: '',
            ),

            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(
                  child: CustomText(
                    textAlign: TextAlign.start,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    text: 'Oliver Finch',
                    maxline: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),

                CustomContainer(
                  radiusAll: 99.r,
                  paddingVertical: 3.h,
                  paddingHorizontal: 6.w,
                  color: AppColors.success,
                  child: Row(
                    children: [
                      Assets.icons.recieved.svg(),
                      CustomText(text: 'Recieved',fontSize: 12.sp,fontWeight: FontWeight.w500,color: Colors.white)
                    ],
                  ),
                ),
              ],
            ),
            subtitle: CustomText(
              fontSize: 12.sp,
              textAlign: TextAlign.start,
              color: AppColors.textSecondary,
              text: 'Restoration assistance - Jan 5 - Jan 14',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: 'Total billed',fontWeight: FontWeight.w600),
              CustomText(text: '\$249.99',fontWeight: FontWeight.w700,color: AppColors.info),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
