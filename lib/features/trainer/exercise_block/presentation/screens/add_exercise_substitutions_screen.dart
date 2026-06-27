import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AddExerciseSubstitutionsScreen extends StatefulWidget {
  const AddExerciseSubstitutionsScreen({super.key});

  @override
  State<AddExerciseSubstitutionsScreen> createState() =>
      _AddExerciseSubstitutionsScreenState();
}

class _AddExerciseSubstitutionsScreenState
    extends State<AddExerciseSubstitutionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = ExerciseBlockController.to;

  void _onDone() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    controller.doneAddingSubstitutions();
  }

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: const CustomSliverAppBar(
        title: 'Substitutions',
      ),
      bodyList: [
        SizedBox(height: 24.h).asSliver,
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'No barbell',
                hintText: 'eg : Dumbbell bench press',
                controller: controller.noBarbellController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter substitution';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'No machine',
                hintText: 'eg : Push-up',
                controller: controller.noMachineController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter substitution';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'Home only',
                hintText: 'eg : Floor press',
                controller: controller.homeOnlyController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter substitution';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'Hotel gym',
                hintText: 'eg : Dumbbell bench press',
                controller: controller.hotelGymController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter substitution';
                  }
                  return null;
                },
              ),
            ],
          ),
        ).asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 120.h).asSliver,
      ],
      bottomNavigationBar: CustomButton(
        onPressed: _onDone,
        label: 'Done',
        width: double.infinity,
      ),
    );
  }
}
