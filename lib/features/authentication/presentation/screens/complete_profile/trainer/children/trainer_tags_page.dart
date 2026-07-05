import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';

class TrainerTagsPage extends StatelessWidget {
  const TrainerTagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CompleteProfilePageTitle(
          text: 'Add your trainer tags',
          center: true,
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
