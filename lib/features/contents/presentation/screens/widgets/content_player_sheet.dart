import 'package:pler_to_pler_app/core/themes/app_typography.dart';
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
                fontWeight: AppFontWeight.section,
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
                        color:
                            selected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: AppFontWeight.label,
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
}
