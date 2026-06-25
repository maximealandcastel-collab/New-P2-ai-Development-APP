import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class DeviceMetricsShimmer extends StatelessWidget {
  const DeviceMetricsShimmer({super.key});

  Widget _box({double? width, double? height, double radius = 12}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _box(height: 120.h, radius: 20),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _box(height: 110.h, radius: 16)),
              SizedBox(width: 10.w),
              Expanded(child: _box(height: 110.h, radius: 16)),
            ],
          ),
          SizedBox(height: 10.h),
          _box(height: 110.h, radius: 16),
          SizedBox(height: 16.h),
          _box(height: 140.h, radius: 20),
        ],
      ),
    );
  }
}
