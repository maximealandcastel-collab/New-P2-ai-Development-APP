import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/simmer_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';

class UserHomeShimmer extends StatelessWidget {
  const UserHomeShimmer({super.key});

  static List<Widget> slivers() {
    return [
      const UserHomeShimmer().asSliverWithPadding(horizontal: 16.w),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGymShimmer(),
        SizedBox(height: 14.h),
        _buildOverviewShimmer(),
        SizedBox(height: 14.h),
        _buildTodayWorkoutShimmer(),
      ],
    );
  }

  Widget _buildGymShimmer() {
    return CustomContainer(
      marginTop: 8.h,
      color: Colors.white,
      radiusAll: 16.r,
      paddingVertical: 14.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(child: ShimmerHelper.textShimmer(width: 80.w, height: 16)),
                ShimmerHelper.textShimmer(width: 60.w, height: 14),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 134.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 4,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, __) => _buildGymCardShimmer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CustomContainer(
        radiusAll: 12.r,
        bordersColor: AppColors.secondary,
        width: 110.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 62.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Container(
                height: 12.h,
                width: 80.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Container(
                height: 10.h,
                width: 60.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Container(
                height: 15.h,
                width: 50.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewShimmer() {
    return CustomContainer(
      color: Colors.white,
      radiusAll: 16.r,
      paddingAll: 14.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerHelper.textShimmer(width: 140.w, height: 16),
          SizedBox(height: 12.h),
          ShimmerHelper.cardShimmer(),
        ],
      ),
    );
  }

  Widget _buildTodayWorkoutShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerHelper.textShimmer(width: 180.w, height: 16),
        SizedBox(height: 12.h),
        ShimmerHelper.categoryCardShimmer(),
        SizedBox(height: 10.h),
        ShimmerHelper.categoryCardShimmer(),
        SizedBox(height: 12.h),
        ShimmerHelper.textShimmer(width: double.infinity, height: 48),
      ],
    );
  }
}
