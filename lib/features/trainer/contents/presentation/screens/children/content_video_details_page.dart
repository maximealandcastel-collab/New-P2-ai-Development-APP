import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentVideoDetailsPage extends StatelessWidget {
  const ContentVideoDetailsPage({
    super.key,
    required this.videoUrlController,
    required this.thumbnailUrlController,
    required this.durationController,
    required this.exerciseNameController,
  });

  final TextEditingController videoUrlController;
  final TextEditingController thumbnailUrlController;
  final TextEditingController durationController;
  final TextEditingController exerciseNameController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Video details',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          labelText: 'Video URL',
          hintText: 'https://storage.example.com/videos/...',
          controller: videoUrlController,
          keyboardType: TextInputType.url,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter video URL';
            }
            return null;
          },
        ),
        CustomTextField(
          labelText: 'Thumbnail URL',
          hintText: 'https://storage.example.com/thumbnails/...',
          controller: thumbnailUrlController,
          keyboardType: TextInputType.url,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter thumbnail URL';
            }
            return null;
          },
        ),
        CustomTextField(
          labelText: 'Duration (seconds)',
          hintText: 'eg : 840',
          controller: durationController,
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
          controller: exerciseNameController,
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
