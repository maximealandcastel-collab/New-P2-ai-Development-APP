import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AddExerciseNameScreen extends StatefulWidget {
  const AddExerciseNameScreen({super.key});

  @override
  State<AddExerciseNameScreen> createState() => _AddExerciseNameScreenState();
}

class _AddExerciseNameScreenState extends State<AddExerciseNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = ExerciseBlockController.to;

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    controller.addExercise(controller.exerciseNameController.text);
    if (mounted) Get.back(result: true);
  }

  @override
  void initState() {
    super.initState();
    controller.exerciseNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: const CustomSliverAppBar(
        title: 'Exercises name',
      ),
      bodyList: [
        SizedBox(height: 24.h).asSliver,
        Form(
          key: _formKey,
          child: CustomTextField(
            borderColor: Colors.transparent,
            labelColor: Colors.black,
            labelText: 'Exercises name',
            hintText: 'eg : Bench press',
            controller: controller.exerciseNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter exercise name';
              }
              return null;
            },
          ),
        ).asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 120.h).asSliver,
      ],
      bottomNavigationBar: CustomButton(
        onPressed: _submit,
        label: 'Add exercise',
        width: double.infinity,
      ),
    );
  }
}
