import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_details_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentPlayerSheet {
  ContentPlayerSheet._();

  static Future<void> showSpeed(
    BuildContext context,
    ContentDetailsController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.primaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'Playback speed',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 12.h),
              Obx(
                () => Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: ContentDetailsController.playbackSpeeds.map((speed) {
                    final selected = controller.playbackSpeed.value == speed;
                    return ChoiceChip(
                      label: Text('${speed}x'),
                      selected: selected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: selected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        controller.setPlaybackSpeed(speed);
                        Get.back();
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showSubtitles(
    BuildContext context,
    ContentDetailsController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.primaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(() {
            final tracks = controller.subtitleTracks;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Subtitles',
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8.h),
                _SubtitleTile(
                  label: 'Off',
                  selected: controller.selectedSubtitle.value == null,
                  onTap: () {
                    controller.disableSubtitles();
                    Get.back();
                  },
                ),
                if (tracks.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: CustomText(
                      text: 'No subtitles available.',
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.start,
                    ),
                  )
                else
                  ...tracks.map(
                    (track) => _SubtitleTile(
                      label: controller.subtitleLabel(track),
                      selected: controller.selectedSubtitle.value?.id == track.id,
                      onTap: () {
                        controller.selectSubtitle(track);
                        Get.back();
                      },
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _SubtitleTile extends StatelessWidget {
  const _SubtitleTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
