import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/core/content_hero_tags.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/video_thumbnail_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.content,
    this.showActions = true,
  });

  final ContentModel content;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final controller = ContentController.to;
    return CustomContainer(
      onTap: () {
        Get.toNamed(
          AppRoute.contentDetailsScreen,
          arguments: content,
        );
      },
      paddingBottom: 16.h,
      border: Border(
        bottom: BorderSide(color: AppColors.secondary, width: 0.5),
      ),
      child: Row(
        children: [
          Hero(
            tag: ContentHeroTags.thumbnail(content.id),
            child: Material(
              color: Colors.transparent,
              child: (content.thumbnailUrl != null && content.thumbnailUrl!.isNotEmpty)
                  ? CustomNetworkImage(
                borderRadius: 8.r,
                width: 96.w,
                height: 74.h,
                imageUrl: content.thumbnailUrl!,
              )
                  : VideoThumbnailWidget(
                videoUrl: content.videoUrl ?? '',
                width: 96.w,
                height: 74.h,
                borderRadius: 8.r,
              ),
            ),
          ),          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  maxline: 2,
                  textOverflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.start,
                  text: content.title ?? '',
                ),
                CustomText(
                  top: 2.h,
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.start,
                  text: TimeFormatHelper.getTimeAgo(content.createdAt),
                ),
                if (showActions) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          fontWeight: FontWeight.w400,
                          radius: 8.r,
                          fontSize: 12.sp,
                          height: 26.h,
                          onPressed: () {
                            Get.toNamed(
                              AppRoute.createContentScreen,
                              arguments: content,
                            );
                          },
                          label: 'Edit',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomButton(
                          fontWeight: FontWeight.w400,
                          backgroundColor: Colors.white,
                          bordersColor: AppColors.error,
                          foregroundColor: AppColors.error,
                          radius: 8.r,
                          fontSize: 12.sp,
                          height: 26.h,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => Obx(
                                () => CustomDialog(
                                  title: 'Delete content?',
                                  description:
                                      'Are you sure you want to delete "${content.title}"? This action cannot be undone.',
                                  isLoading:
                                      controller.deleteLoadingState.isLoading,
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
                          },
                          label: 'Delete',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
