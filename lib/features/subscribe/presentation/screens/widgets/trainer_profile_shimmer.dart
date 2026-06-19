import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/simmer_helper.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerProfileShimmer {
  TrainerProfileShimmer._();

  static Widget headerShimmer() {
    return CustomContainer(
      child: Stack(
        children: [
          ShimmerHelper.textShimmer(
            width: double.infinity,
            height: 210,
          ),
          Positioned(
            top: 132.h,
            left: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerHelper.textShimmer(
                  width: 136.r,
                  height: 136.r,
                ),
                SizedBox(height: 6.h),
                ShimmerHelper.textShimmer(width: 160.w, height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> contentSlivers() => [
        SizedBox(height: 20.h).asSliver,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ShimmerHelper.textShimmer(
            width: double.infinity,
            height: 48,
          ),
        ).asSliver,
        SizedBox(height: 24.h).asSliver,
        ...List.generate(4, (_) => _bioCardShimmer().asSliver),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: ShimmerHelper.cardShimmer(),
        ).asSliver,
        SizedBox(height: 60.h).asSliver,
      ];

  static Widget _bioCardShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerHelper.textShimmer(width: 80.w, height: 14),
          SizedBox(height: 6.h),
          ShimmerHelper.textShimmer(width: double.infinity, height: 16),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
