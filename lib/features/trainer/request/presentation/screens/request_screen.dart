import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/widgets/session_card.dart';
import 'package:pler_to_pler_app/widgets/custom_search_field.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        FeedAppBarSliver(
          pinned: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(58.h),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w,0,16.w,8.h),
              child: CustomSearchField(hintText: 'Search by name or condition'),
            ),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 130.h),
          sliver: SliverList.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return RequestCard();
            },
          ),
        ),
      ],
    );
  }
}
