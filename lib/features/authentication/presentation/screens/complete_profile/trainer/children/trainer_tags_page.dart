import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerTagsPage extends StatefulWidget {
  const TrainerTagsPage({super.key});

  @override
  State<TrainerTagsPage> createState() => _TrainerTagsPageState();
}

class _TrainerTagsPageState extends State<TrainerTagsPage> {
  final List<String> _tags = [];

  @override
  Widget build(BuildContext context) {
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
          onTagsChanged: (updatedTags) => _tags.addAll(updatedTags),
        ),
      ],
    );
  }
}
