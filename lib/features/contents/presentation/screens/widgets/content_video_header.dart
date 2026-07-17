import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/core/content_hero_tags.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_details_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_thumbnail_placeholder.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_video_player.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentVideoHeader extends StatelessWidget {
  const ContentVideoHeader({
    super.key,
    required this.content,
    required this.controller,
  });

  final ContentModel content;
  final ContentDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = ContentMediaResolver.resolveThumbnailUrl(content);

    return ColoredBox(
      color: AppColors.backgroundLight,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Hero(
          tag: ContentHeroTags.thumbnail(content.id),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: ContentVideoPlayer(
                  controller: controller,
                  borderRadius: BorderRadius.circular(12.r),
                  poster: thumbnailUrl.isNotEmpty
                      ? CustomNetworkImage(
                          width: double.infinity,
                          height: double.infinity,
                          imageUrl: thumbnailUrl,
                          fit: BoxFit.cover,
                          backgroundColor: AppColors.backgroundDark,
                          fallbackAsset: ContentThumbnailPlaceholder(
                            title: content.title,
                          ),
                        )
                      : ContentThumbnailPlaceholder(title: content.title),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
