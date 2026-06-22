import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentEquipmentTagsPage extends StatelessWidget {
  const ContentEquipmentTagsPage({
    super.key,
    required this.onEquipmentChanged,
    required this.onTagsChanged,
  });

  final ValueChanged<List<String>> onEquipmentChanged;
  final ValueChanged<List<String>> onTagsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CustomText(
            text: 'Equipment & tags',
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        TagAddWidget(
          labelText: 'Equipment',
          hintText: 'eg : barbell',
          onTagsChanged: onEquipmentChanged,
        ),
        SizedBox(height: 8.h),
        TagAddWidget(
          labelText: 'Tags',
          hintText: 'eg : bench press',
          onTagsChanged: onTagsChanged,
        ),
      ],
    );
  }
}
