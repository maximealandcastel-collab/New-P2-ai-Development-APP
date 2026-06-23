import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/home/widgets/gym_section.dart';
import 'package:pler_to_pler_app/features/home/widgets/overview_section.dart';
import 'package:pler_to_pler_app/features/home/widgets/week_date_picker.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        FeedAppBarSliver(
          //pinned: true,
        ),
        WeekDatePicker(
          onDateSelected: (date) {
            print('Selected: $date');
          },
        ).asSliver,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Assets.images.setGoal.image(),
        ).asSliverWithPadding(horizontal: 16.w, vertical: 10.h),


        GymSection().asSliverWithPadding(horizontal: 16.w),
        OverviewSection().asSliverWithPadding(horizontal: 16.w,vertical: 14.h),


        SizedBox(height: 16.h).asSliver,
        SliverToBoxAdapter(child: SizedBox(height: 120.h)),
      ],
    );
  }
}
