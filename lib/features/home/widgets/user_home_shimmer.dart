import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      paddingAll: 14.r,
      child: _shimmerWrap(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _box(height: 16)),
                SizedBox(width: 12.w),
                _box(width: 56.w, height: 14),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 110.h,
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < 2 ? 8.w : 0),
                      child: _box(height: 110),
                    ),
                  );
                }),
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
      child: _shimmerWrap(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(width: 140.w, height: 16),
            SizedBox(height: 12.h),
            CustomContainer(
              paddingAll: 16.r,
              bordersColor: AppColors.secondary,
              radiusAll: 16.r,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(width: 72.w, height: 72, radius: 36),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          children: [
                            _box(height: 34),
                            SizedBox(height: 8.h),
                            _box(height: 34),
                            SizedBox(height: 8.h),
                            _box(height: 34),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _box(height: 14),
                  SizedBox(height: 8.h),
                  _box(height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayWorkoutShimmer() {
    return _shimmerWrap(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: 180.w, height: 16),
          SizedBox(height: 12.h),
          CustomContainer(
            radiusAll: 16.r,
            paddingAll: 14.r,
            bordersColor: AppColors.secondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 150.w, height: 16),
                SizedBox(height: 10.h),
                _box(height: 12),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _box(width: 56.w, height: 24, radius: 8),
                    SizedBox(width: 8.w),
                    _box(width: 56.w, height: 24, radius: 8),
                    SizedBox(width: 8.w),
                    _box(width: 56.w, height: 24, radius: 8),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          _box(height: 48, radius: 12),
        ],
      ),
    );
  }

  Widget _shimmerWrap(Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  Widget _box({
    double? width,
    required double height,
    double radius = 12,
  }) {
    return Container(
      width: width,
      height: height.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}
