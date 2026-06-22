import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentCategoryScreen extends StatelessWidget {
  const ContentCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBarTitle: 'All category',
      slivers: (context) => [
        CustomText(
          left: 16.w,
          bottom: 12.h,
          textAlign: TextAlign.start,
          fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            text: 'Categories').asSliver,
      SliverList.separated(
    itemCount: 10,
      itemBuilder: (_, i) {
        return CustomContainer(
          radiusAll: 12.r,
          paddingAll: 14.r,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      textAlign: TextAlign.start,
                      maxline: 1,
                      textOverflow: TextOverflow.ellipsis,
                      text: 'Muscles gain',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  GestureDetector(
                    onTapDown: (details){
                      MenuShowHelper.showCustomMenu(context: context, details: details, options: ['Edit','Delete']);
                    },
                    behavior: HitTestBehavior.opaque,
                      child: Icon(Icons.more_vert_outlined,size: 20.r,)),
                ],
              ),

              CustomText(
                textAlign: TextAlign.start,
                maxline: 2,
                textOverflow: TextOverflow.ellipsis,
                text: 'Please provide your information carefully. We are collecting this data to train your . . .',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
    ).asPaddedSliver(horizontal: 16.w),
        SizedBox(height: 70.h).asSliver,
      ],

      floatingActionButton: IconButton(onPressed: (){
        Get.toNamed(AppRoute.createCategoryScreen);
      },icon: Assets.icons.addButton.svg(height: 57.r,width: 57.r),),
    );
  }
}


