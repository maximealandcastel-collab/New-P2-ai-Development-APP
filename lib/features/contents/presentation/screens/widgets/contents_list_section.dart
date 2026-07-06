import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_card.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_shimmer.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsListSection extends StatelessWidget {
  const ContentsListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final contentController = ContentController.to;

    return Obx(() {
      switch (contentController.loadingState) {
        case LoadingState.initial:
        case LoadingState.loading:
          return const ContentShimmer().asSliver;
        case LoadingState.offline:
        case LoadingState.error:
          return CustomContainer(
            horizontalMargin: 16.h,
            bottomLeft: 16.r,
            bottomRight: 16.r,
            paddingBottom: 16.h,
            color: Colors.white,
            child: EmptyDataWidget(
              message: 'Content not found ',
              onRefresh: contentController.refresh,
            ),
          ).asSliver;
        case LoadingState.loaded:
          final isTrainer =
              ProfileController.to.userData?.role == 'trainer';
          final showActions = isTrainer &&
              (contentController.activeTab.value != ContentTab.defaultContent);

          return SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
            sliver: SliverList.builder(
              itemCount: contentController.contents.length,
              itemBuilder: (context, index) {
                final content = contentController.contents[index];
                return CustomContainer(
                  color: Colors.white,
                  paddingTop: 8.h,
                  paddingLeft: 16.w,
                  paddingRight: 16.w,
                  child: ContentCard(
                    content: content,
                    showActions: showActions,
                  ),
                );
              },
            ),
          );
      }
    });
  }
}
