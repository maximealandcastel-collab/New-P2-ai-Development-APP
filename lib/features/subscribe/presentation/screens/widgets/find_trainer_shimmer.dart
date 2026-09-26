import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class FindTrainerShimmer extends StatelessWidget {
  const FindTrainerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Each instance occupies one bounded grid cell, just like FindTrainerCard.
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
