import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/exercise_block_controller.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = ExerciseBlockController.to;

  List<String> _formatOptions(List<String> options) =>
      options.map(StringFormat.formatLabel).toList();

  void _onAddSteps() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    controller.onOpenExerciseSteps();
  }

  void _createExercise() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    controller.saveExercise();
  }

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: const CustomSliverAppBar(
        title: 'Add exercise',
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
              MenuDropdownField(
                labelText: 'Muscle group',
                hintText: 'Select muscle group',
                controller: controller.exerciseMuscleGroupController,
                options: _formatOptions(HelperData.muscleGroupOptions),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select muscle group';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              MenuDropdownField(
                labelText: 'Difficulty',
                hintText: 'Select difficulty',
                controller: controller.exerciseDifficultyController,
                options: _formatOptions(
                  HelperData.contentDifficultyOptions
                      .where((item) => item != 'all')
                      .toList(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select difficulty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              MenuDropdownField(
                labelText: 'Equipment',
                hintText: 'Select equipment',
                controller: controller.exerciseEquipmentController,
                options: _formatOptions(HelperData.exerciseEquipmentOptions),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select equipment';
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
              SizedBox(height: 20.h),
              CustomText(
                text: 'Substitutions',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 24.h),
              Obx(() {
                if (controller.hasSubstitutions) {
                  return CustomContainer(
                    width: double.infinity,
                    marginBottom: 8.h,
                    paddingHorizontal: 12.w,
                    paddingVertical: 12.h,
                    radiusAll: 12.r,
                    color: Colors.white,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: 'Substitutions',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.start,
                              ),
                              ...controller.draftSubstitutions.entries.map(
                                (entry) {
                                  final label = ExerciseBlockController
                                          .substitutionLabels[entry.key] ??
                                      entry.key;
                                  return CustomText(
                                    top: 6.h,
                                    text: '$label: ${entry.value}',
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                    textAlign: TextAlign.start,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: controller.removeSubstitutions,
                          child: Icon(
                            Icons.delete_outline,
                            size: 22.sp,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return CustomButton(
                  onPressed: controller.onOpenSubstitutions,
                  label: 'Add substitutions',
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
                );
              }),
              SizedBox(height: 12.h),
              Obx(
                () => TagAddWidget(
                  labelText: 'Tags',
                  hintText: 'Add tag',
                  initialTags: controller.exerciseTags.toList(),
                  onTagsChanged: controller.onExerciseTagsChanged,
                ),
              ),
              SizedBox(height: 20.h),
              CustomText(
                text: 'Created steps',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                onPressed: _onAddSteps,
                label: 'Add steps',
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
                if (controller.draftSteps.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: List.generate(controller.draftSteps.length, (index) {
                    final step = controller.draftSteps[index];
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
                            child: CustomText(
                              text: step.instruction,
                              fontSize: 16.sp,
                              maxline: 1,
                              textOverflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w600,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.removeDraftStep(index),
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
      bottomNavigationBar: CustomButton(
        onPressed: _createExercise,
        label: 'Create exercise',
        width: double.infinity,
      ),
    );
  }
}
