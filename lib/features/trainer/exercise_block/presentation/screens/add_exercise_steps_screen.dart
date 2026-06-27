import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AddExerciseStepsScreen extends StatefulWidget {
  const AddExerciseStepsScreen({super.key});

  @override
  State<AddExerciseStepsScreen> createState() => _AddExerciseStepsScreenState();
}

class _AddExerciseStepsScreenState extends State<AddExerciseStepsScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = ExerciseBlockController.to;

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: const CustomSliverAppBar(
        title: 'Exercise steps',
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
                labelText: 'Instruction',
                hintText: 'Describe the movement',
                controller: controller.stepInstructionController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter instruction';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                contentPaddingVertical: 10.h,
                minLines: 5,
                maxLines: 5,
                labelText: 'Tip',
                hintText: 'Optional coaching tip',
                controller: controller.stepTipController,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ).asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 120.h).asSliver,
      ],
      bottomNavigationBar: CustomButton(
        onPressed: () {
          if (!(_formKey.currentState?.validate() ?? false)) return;
          controller.doneAddingSteps();
        },
        label: 'Done',
        width: double.infinity,
      ),
    );
  }
}
