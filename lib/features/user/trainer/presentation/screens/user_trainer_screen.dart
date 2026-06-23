import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/widgets/client_card_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class UserTrainerScreen extends StatelessWidget {
  const UserTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        FeedAppBarSliver(),
        SizedBox(height: 16.h).asSliver,
        ClientCardWidget().asSliverWithPadding(horizontal: 16.h),
        SliverToBoxAdapter(child: SizedBox(height: 120.h)),
      ],
    );
  }
}
