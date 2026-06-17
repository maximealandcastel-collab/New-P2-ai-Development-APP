import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SpecialityPage extends StatelessWidget {
  const SpecialityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Add your speciality',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTapDown: (details) {
            final menu = MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: MenuShowHelper.specialityDisplayOptions,
            );
            menu.then((value) {
              if (value != null) {
                controller.specialityController.text = value;
              }
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Speciality',
              hintText: 'Select speciality',
              controller: controller.specialityController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select your speciality';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
