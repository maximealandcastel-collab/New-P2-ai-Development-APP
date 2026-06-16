import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/widgets/dynamic_field_list_widget.dart';

class CertificationsPage extends StatelessWidget {
  const CertificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DynamicFieldListWidget(
          title: 'Add your certifications',
          onChanged: controller.setCertifications,
        ),
      ],
    );
  }
}
