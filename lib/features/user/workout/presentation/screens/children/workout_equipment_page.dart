import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/widgets/workout_multi_select_field.dart';

class WorkoutEquipmentPage extends StatelessWidget {
  const WorkoutEquipmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutController.to;

    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CompleteProfilePageTitle(text: 'What equipment do you have?'),
          SizedBox(height: 24.h),
          WorkoutMultiSelectField(
            options: HelperData.workoutEquipmentOptions,
            selectedValues: controller.selectedEquipment.toList(),
            onChanged: controller.onEquipmentChanged,
          ),
        ],
      ),
    );
  }
}
