import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_details_info.dart';
import 'package:pler_to_pler_app/features/contents/reels/presentation/widgets/reel_player.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentReelItem extends StatelessWidget {
  const ContentReelItem({
    super.key,
    required this.content,
    required this.index,
  });

  final ContentModel content;
  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = ContentController.to;

    return Stack(
      fit: StackFit.expand,
      children: [
        ReelPlayer(
          content: content,
          index: index,
          reelController: controller.reel,
          contents: controller.contents,
        ),
        _buildSideActions(context, controller),
      ],
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 16.h;
    final chips = <String>[
      if (content.durationSeconds != null)
        _formatDuration(content.durationSeconds!),
      if (content.viewCount != null) '${content.viewCount} views',
    ];

    return Positioned(
      left: 16.w,
      right: 88.w,
      bottom: bottomInset + 4.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: content.title ?? 'Untitled content',
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: AppColors.textWhite,
            maxline: 2,
            textOverflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
          if (chips.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: chips
                  .map((label) => ContentDetailChip(label: label))
                  .toList(),
            ),
          ],
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildSideActions(BuildContext context, ContentController controller) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 16.h;
    final isTrainer = ProfileController.to.userData?.role == 'trainer';

    return Positioned(
      right: 12.w,
      bottom: bottomInset,
      child: Obx(() {
        // Read Rx first so Obx always has a dependency (avoids GetX error when
        // isTrainer is false and the && short-circuits before .value).
        final activeTab = controller.activeTab.value;
        final showTrainerActions =
            isTrainer && activeTab != ContentTab.defaultContent;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: Icons.info_outline_rounded,
              label: 'Info',
              onTap: () {
                controller.pauseReel();
                Get.toNamed(AppRoute.contentDetailsScreen, arguments: content);
              },
            ),
            if (showTrainerActions) ...[
              SizedBox(height: 16.h),
              _buildActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: () {
                  Get.toNamed(AppRoute.createContentScreen, arguments: content);
                },
              ),
              SizedBox(height: 16.h),
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                onTap: () => _showDeleteDialog(context, controller),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 22.r),
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: label,
            fontSize: 11.sp,
            color: AppColors.textWhite,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ContentController controller) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Obx(
        () => CustomDialog(
          title: 'Delete content?',
          description:
              'Are you sure you want to delete "${content.title}"? This action cannot be undone.',
          isLoading: controller.deleteLoadingState.isLoading,
          rightButtonLabel: 'Yes, Delete',
          onTapLeftButton: () => Get.back(),
          onTapRightButton: () {
            if (content.id != null) {
              controller.deleteContent(content.id!);
            }
          },
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$secs' : '$minutes:$secs';
  }
}
