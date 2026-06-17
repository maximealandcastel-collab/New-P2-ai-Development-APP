import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
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
        Center(
          child: CustomText(
            text: 'Add your gym info?',
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTapDown: (details) {
            MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: MenuShowHelper.equipmentDisplayOptions,
            ).then((value) {
              if (value != null) {
                controller.equipmentController.text = value;
              }
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Available equipment',
              hintText: 'Select equipment',
              controller: controller.equipmentController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select your available equipment';
                }
                return null;
              },
            ),
          ),
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
