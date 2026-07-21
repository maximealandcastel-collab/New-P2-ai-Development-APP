import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/simmer_helper.dart';

class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      child: Column(
        children: List.generate(
          itemCount,
          (_) => Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: ShimmerHelper.categoryCardShimmer(),
          ),
        ),
      ),
    );
  }
}
