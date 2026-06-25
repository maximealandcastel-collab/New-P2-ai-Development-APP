import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/create_content_controller.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';

class ContentEquipmentTagsPage extends StatelessWidget {
  const ContentEquipmentTagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CreateContentController.to;

    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CompleteProfilePageTitle(text: 'Equipment & tags', center: true),
          SizedBox(height: 16.h),
          TagAddWidget(
            labelText: 'Equipment',
            hintText: 'eg : barbell',
            initialTags: controller.equipment.toList(),
            onTagsChanged: controller.onEquipmentChanged,
          ),
          SizedBox(height: 8.h),
          TagAddWidget(
            labelText: 'Tags',
            hintText: 'eg : bench press',
            initialTags: controller.tags.toList(),
            onTagsChanged: controller.onTagsChanged,
          ),
        ],
      ),
    );
  }
}
