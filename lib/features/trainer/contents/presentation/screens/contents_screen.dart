import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/widgets/content_card.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsScreen extends StatelessWidget {
  const ContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
         FeedAppBarSliver(
           pinned: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(98.h),
            child: Padding(
              padding:  EdgeInsets.fromLTRB(16.w,0.h,16.w,0),
              child: CustomContainer(
                topLeftRadius: 16.r,
                topRightRadius: 16.r,
                paddingTop: 16.h,
                paddingBottom: 8.h,
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      left: 16.w,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                      text: 'All Contents',
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 40.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 20,
                        itemBuilder: (context, index) {
                          return CustomContainer(
                            bordersColor: AppColors.secondary,
                            radiusAll: 99.r,
                            marginTop: 3.h,
                            marginLeft: index == 0 ? 10.w : 0,
                            marginBottom: 3.h,
                            marginRight: 6.w,
                            paddingVertical: 6.h,
                            paddingHorizontal: 12.r,
                            color: Colors.transparent,
                            child: CustomText(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: AppColors.textSecondary,
                              text: 'Muscles gain',
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
          sliver: SliverList.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return CustomContainer(
                color: Colors.white,
                paddingLeft: 16.w,
                paddingRight: 16.w,
                child: ContentCard(),
              );
            },
          ),
        ),
      ],
    );
  }
}
