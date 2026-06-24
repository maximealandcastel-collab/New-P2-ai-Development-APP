import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/widgets/dynamic_field_list_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class GymInfoPage extends StatelessWidget {
  const GymInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CompleteProfilePageTitle(
          text: 'Add your gym info?',
          center: true,
        ),
        SizedBox(height: 16.h),
        MenuDropdownField(
          labelText: 'Available equipment',
          hintText: 'Select equipment',
          controller: controller.equipmentController,
          options: MenuShowHelper.equipmentDisplayOptions,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select your available equipment';
            }
            return null;
          },
        ),
        CustomTextField(
          labelText: 'Weekly training days',
          hintText: 'Eg : 4',
          keyboardType: TextInputType.number,
          controller: controller.trainingDaysController,
          inputFormatter: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your weekly training days';
            }
            final days = int.tryParse(value.trim());
            if (days == null || days <= 0 || days > 7) {
              return 'Please enter a valid number of days (1-7)';
            }
            return null;
          },
        ),
        DynamicFieldListWidget(
          title: 'Injuries',
          onChanged: controller.setInjuries,
        ),
      ],
    );
  }
}
