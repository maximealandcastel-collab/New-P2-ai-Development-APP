import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/create_exercise_block_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class GenerateExerciseBlockScreen extends StatefulWidget {
  const GenerateExerciseBlockScreen({super.key});

  @override
  State<GenerateExerciseBlockScreen> createState() =>
      _GenerateExerciseBlockScreenState();
}

class _GenerateExerciseBlockScreenState
    extends State<GenerateExerciseBlockScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = CreateExerciseBlockController.to;

  List<String> get _categoryOptions => HelperData.muscleGroupOptions
      .map(StringFormat.formatLabel)
      .toList();

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await controller.generateBlock();
    if (success && mounted) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: const CustomSliverAppBar(
        title: 'Generate exercise',
      ),
      bodyList: [
        Center(
          child: CustomContainer(
            width: 88.w,
            height: 88.w,
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 40.sp,
              color: AppColors.primary,
            ),
          ),
        ).asSliver,
        CustomText(
          top: 20.h,
          text: 'AI exercise block',
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.center,
        ).asSliverWithPadding(horizontal: 20.w),
        SizedBox(height: 24.h).asSliver,
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'Exercise block name',
                hintText: 'eg : muscles gain',
                controller: controller.blockNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter block name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              MenuDropdownField(
                labelText: 'Exercise category',
                hintText: 'Select category',
                controller: controller.categoryController,
                options: _categoryOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'Exercise count',
                hintText: 'e.g. 2',
                controller: controller.countController,
                keyboardType: TextInputType.number,
                inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  final count = int.tryParse(value?.trim() ?? '');
                  if (count == null || count < 1) {
                    return 'Enter a valid exercise count';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                contentPaddingVertical: 16.w,
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'Context',
                hintText:
                    'Maintenance clients, moderate intensity, compound movements...',
                minLines: 5,
                maxLines: 5,
                controller: controller.contextController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter context for AI';
                  }
                  return null;
                },
              ),
            ],
          ),
        ).asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 120.h).asSliver,
      ],
      bottomNavigationBar: Obx(
        () => CustomButton(
          onPressed: _submit,
          isLoading: controller.generateLoadingState.isLoading,
          label: 'Generate plan',
          width: double.infinity,
        ),
      ),
    );
  }
}
