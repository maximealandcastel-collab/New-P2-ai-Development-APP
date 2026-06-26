import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_details_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_details_info.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_video_header.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_video_player.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentDetailsScreen extends StatelessWidget {
  const ContentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ContentDetailsController.to;
    final content = controller.content;
    final videoHeight = 1.sw * 9 / 16;

    final page = SliverScaffold(
      appBar: CustomSliverAppBar(
        pinned: true,
        safeArea: false,
        centerTitle: false,
        expandedHeight: videoHeight + kToolbarHeight,
        collapsedTitle: content.title ?? 'Content details',
        collapsedTitleColor: AppColors.textPrimary,
        foregroundColor: AppColors.textPrimary,
        backAction: Get.back,
        flexibleBackground: ContentVideoHeader(
          content: content,
          controller: controller,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          ContentDetailsInfo(content: content).asSliverWithPadding(horizontal: 16.w),
          SizedBox(height: 24.h).asSliver,
        ],
      ),
    );

    return PiPSwitcher(
      childWhenDisabled: page,
      childWhenEnabled: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: ContentVideoPlayer(
            controller: controller,
            showActions: false,
          ),
        ),
      ),
    );
  }
}
