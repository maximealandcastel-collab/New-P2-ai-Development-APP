import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AddExerciseDetailsPage extends StatelessWidget {
  const AddExerciseDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ExerciseBlockController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CompleteProfilePageTitle(text: 'Exercise details'),
        SizedBox(height: 16.h),
        CustomTextField(
          borderColor: Colors.transparent,
          labelColor: Colors.black,
          labelText: 'Exercise name',
          hintText: 'eg : Bench press',
          controller: controller.exerciseNameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter exercise name';
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        CustomTextField(
          borderColor: Colors.transparent,
          labelColor: Colors.black,
          labelText: 'Sets',
          hintText: 'eg : 4',
          controller: controller.exerciseSetsController,
          keyboardType: TextInputType.number,
          inputFormatter: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            final sets = int.tryParse(value?.trim() ?? '');
            if (sets == null || sets < 1) {
              return 'Enter valid sets';
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        CustomTextField(
          borderColor: Colors.transparent,
          labelColor: Colors.black,
          labelText: 'Reps',
          hintText: 'eg : 8-10',
          controller: controller.exerciseRepsController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter reps';
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        CustomTextField(
          borderColor: Colors.transparent,
          labelColor: Colors.black,
          labelText: 'Rest time',
          hintText: 'eg : 90s',
          controller: controller.exerciseRestTimeController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter rest time';
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),
        CustomTextField(
          borderColor: Colors.transparent,
          labelColor: Colors.black,
          labelText: 'RPE',
          hintText: 'eg : 7-8',
          controller: controller.exerciseRpeController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter RPE';
            }
            return null;
          },
        ),
      ],
    );
  }
}
