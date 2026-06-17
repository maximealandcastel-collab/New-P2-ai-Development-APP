import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AdditionalInfoPage extends StatelessWidget {
  const AdditionalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'What\'s your additional\ninfo?',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          labelText: 'Preferred name',
          hintText: 'Eg : john',
          controller: controller.preferredNameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your preferred name';
            }
            return null;
          },
        ),
        GestureDetector(
          onTapDown: (details) {
            final menu = MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: MenuShowHelper.motivationStyleDisplayOptions,
            );
            menu.then((value) {
              if (value != null) {
                controller.motivationStyleController.text = value;
              }
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Motivation style',
              hintText: 'Select motivation (e.g. balanced)',
              controller: controller.motivationStyleController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select your motivation style';
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
