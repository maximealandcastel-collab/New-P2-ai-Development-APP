import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/simmer_helper.dart';

class DeviceShimmer extends StatelessWidget {
  const DeviceShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Column(
        children: List.generate(
          itemCount,
          (_) => ShimmerHelper.deviceTileShimmer(),
        ),
      ),
    );
  }
}
