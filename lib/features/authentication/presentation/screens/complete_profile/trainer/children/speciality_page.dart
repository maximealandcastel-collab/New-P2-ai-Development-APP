import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SpecialityPage extends StatelessWidget {
  const SpecialityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CompleteProfilePageTitle(text: 'Add your speciality'),
        SizedBox(height: 16.h),
        MenuDropdownField(
          labelText: 'Speciality',
          hintText: 'Select speciality',
          controller: controller.specialityController,
          options: HelperData.specialityDisplayOptions,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select your speciality';
            }
            return null;
          },
        ),
      ],
    );
  }
}
