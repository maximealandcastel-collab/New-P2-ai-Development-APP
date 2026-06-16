import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerTagsPage extends StatelessWidget {
  const TrainerTagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CustomText(
            text: 'Add your trainer tags',
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        TagAddWidget(
          labelText: '',
          maxTags: 5,
          hintText: 'Write here ...',
          onTagsChanged: controller.setTrainingStyleTags,
        ),
      ],
    );
  }
}
