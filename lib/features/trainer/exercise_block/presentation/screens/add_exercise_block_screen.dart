import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AddExerciseBlockScreen extends StatefulWidget {
  const AddExerciseBlockScreen({super.key});

  @override
  State<AddExerciseBlockScreen> createState() => _AddExerciseBlockScreenState();
}

class _AddExerciseBlockScreenState extends State<AddExerciseBlockScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = ExerciseBlockController.to;

  List<String> get _categoryOptions => HelperData.muscleGroupOptions
      .map(StringFormat.formatLabel)
      .toList();

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (controller.draftExercises.isEmpty) {
      ToastMessageHelper.show('Please add at least one exercise');
      return;
    }
    final success = await controller.createBlock();
    if (success && mounted) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: const CustomSliverAppBar(
        title: 'Add exercise block',
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
              CustomTextField(
                contentPaddingVertical: 16.w,
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'Description',
                hintText: 'Write here . . .',
                minLines: 5,
                maxLines: 5,
                controller: controller.descriptionController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
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
              SizedBox(height: 20.h),
              CustomText(
                text: 'Created exercise',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                onPressed: controller.onOpenAddExercise,
                label: 'Add exercise',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                bordersColor: AppColors.primary,
                radius: 16.r,
                prefixIcon: Icon(
                  Icons.add_rounded,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
                prefixIconShow: true,
              ),
              SizedBox(height: 12.h),
              Obx(() {
                if (controller.draftExercises.isEmpty) {
                  return SizedBox.shrink();
                }

                return Column(
                  children: List.generate(controller.draftExercises.length, (index) {
                    final exercise = controller.draftExercises[index];
                    return CustomContainer(
                      width: double.infinity,
                      marginBottom: 8.h,
                      paddingHorizontal: 12.w,
                      paddingVertical: 12.h,
                      radiusAll: 12.r,
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: exercise.name,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  textAlign: TextAlign.start,
                                ),
                                CustomText(
                                  top: 4.h,
                                  text:
                                      '${StringFormat.formatLabel(exercise.muscleGroup)} · ${exercise.sets} sets · ${exercise.steps.length} steps',
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.removeExercise(index),
                            child: Icon(
                              Icons.delete_outline,
                              size: 22.sp,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                );
              }),

            ],
          ),
        ).asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 120.h).asSliver,
      ],
      bottomNavigationBar: Obx(
        () => CustomButton(
          onPressed: _submit,
          isLoading: controller.createLoadingState.isLoading,
          label: 'Save and continue',
          width: double.infinity,
        ),
      ),
    );
  }
}
