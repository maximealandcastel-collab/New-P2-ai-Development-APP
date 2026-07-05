import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/screens/widgets/workout_multi_select_field.dart';

class WorkoutFocusAreaPage extends StatelessWidget {
  const WorkoutFocusAreaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WorkoutController.to;

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CompleteProfilePageTitle(text: 'Which areas to focus on?'),
          SizedBox(height: 24.h),
          WorkoutMultiSelectField(
            options: HelperData.workoutFocusAreaOptions,
            selectedValues: controller.selectedFocusAreas.toList(),
            onChanged: controller.onFocusAreasChanged,
          ),
        ],
      ),
    );
  }
}
