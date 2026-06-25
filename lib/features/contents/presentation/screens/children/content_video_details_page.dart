import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/create_content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_media_picker_tile.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentVideoDetailsPage extends StatelessWidget {
  const ContentVideoDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CreateContentController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CompleteProfilePageTitle(text: 'Video details'),
        SizedBox(height: 16.h),
        Obx(
          () {
            final hasThumbnailPreview = controller.thumbnailFile != null ||
                controller.existingThumbnailUrl.value != null;

            return ContentMediaPickerTile(
              label: 'Video file',
              hint: 'Upload training video',
              icon: Icons.videocam_outlined,
              isVideo: true,
              fileName: controller.videoFileName.value,
              localImagePath: hasThumbnailPreview && controller.thumbnailFile != null
                  ? controller.thumbnailPreviewPath.value
                  : null,
              remoteImageUrl: hasThumbnailPreview && controller.thumbnailFile == null
                  ? controller.existingThumbnailUrl.value
                  : null,
              onTap: controller.pickVideo,
            );
          },
        ),
        SizedBox(height: 16.h),
        Obx(
          () => ContentMediaPickerTile(
            label: 'Thumbnail image',
            hint: 'Upload thumbnail image',
            icon: Icons.image_outlined,
            fileName: controller.thumbnailFile != null
                ? controller.thumbnailPreviewPath.value?.split('/').last
                : (controller.existingThumbnailUrl.value != null
                    ? 'Current thumbnail'
                    : null),
            localImagePath: controller.thumbnailFile != null
                ? controller.thumbnailPreviewPath.value
                : null,
            remoteImageUrl: controller.thumbnailFile == null
                ? controller.existingThumbnailUrl.value
                : null,
            onTap: () => controller.pickThumbnail(context),
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          labelText: 'Duration (seconds)',
          hintText: 'eg : 840',
          controller: controller.durationController,
          keyboardType: TextInputType.number,
          inputFormatter: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter duration';
            }
            return null;
          },
        ),
        CustomTextField(
          labelText: 'Exercise name',
          hintText: 'eg : Bench Press',
          controller: controller.exerciseNameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter exercise name';
            }
            return null;
          },
        ),
      ],
    );
  }
}
