import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/simmer_helper.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutPlanDetailsShimmer {
  WorkoutPlanDetailsShimmer._();

  static List<Widget> contentSlivers() => [
        SizedBox(height: 12.h).asSliver,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ShimmerHelper.cardShimmer(),
        ).asSliver,
        SizedBox(height: 12.h).asSliver,
        ...List.generate(
          3,
          (_) => Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
            child: ShimmerHelper.categoryCardShimmer(),
          ).asSliver,
        ),
        SizedBox(height: 200.h).asSliver,
      ];
}
