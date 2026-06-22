import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/simmer_helper.dart';

class ContentShimmer extends StatelessWidget {
  const ContentShimmer({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Column(
        children: List.generate(
          itemCount,
          (_) => ShimmerHelper.contentCardShimmer(),
        ),
      ),
    );
  }
}
