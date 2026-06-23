import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/home/widgets/week_date_picker.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/widgets/client_card_widget.dart';
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
          pinned: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(120.h),
            child: WeekDatePicker(
              onDateSelected: (date) {
                print('Selected: $date');
              },
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Assets.images.setGoal.image(),
        ).asSliverWithPadding(horizontal: 16.w, vertical: 10.h),
        
        SizedBox(height: 16.h).asSliver,
        SliverToBoxAdapter(child: SizedBox(height: 120.h)),
      ],
    );
  }
}
