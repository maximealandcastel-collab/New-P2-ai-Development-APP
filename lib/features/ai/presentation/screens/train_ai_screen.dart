import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/widgets/dynamic_field_list_widget.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainAiScreen extends StatelessWidget {
  const TrainAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainAiController.to;

    return SliverScaffold(
      appBarTitle: 'Train your personal AI',
      floating: false,
      slivers: (BuildContext context) => [
        Form(
          key: controller.formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16.h),
                CustomTextField(
                  keyboardType: TextInputType.number,
                  borderColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  labelText: 'Days per week',
                  hintText: 'eg : 4 days',
                  controller: controller.daysPerWeekController,
                  validator: (value) {
                    final days = int.tryParse(value?.trim() ?? '');
                    if (days == null || days < 1 || days > 7) {
                      return 'Enter days between 1 and 7';
                    }
                    return null;
                  },
                ),
                TagAddWidget(
                  labelText: 'Preferred Splits',
                  hintText: 'Write here ...',
                  initialTags: controller.preferredSplits,
                  onTagsChanged: controller.setPreferredSplits,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        keyboardType: TextInputType.number,
                        borderColor: Colors.transparent,
                        labelColor: AppColors.textPrimary,
                        labelText: 'Raps range',
                        hintText: 'min : 8',
                        controller: controller.repRangeMinController,
                        validator: (value) {
                          final min = int.tryParse(value?.trim() ?? '');
                          if (min == null || min < 1) {
                            return 'Enter min reps (e.g. 8)';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CustomTextField(
                        keyboardType: TextInputType.number,
                        borderColor: Colors.transparent,
                        labelColor: AppColors.textPrimary,
                        labelText: '',
                        hintText: 'max : 20',
                        controller: controller.repRangeMaxController,
                        validator: (value) {
                          final max = int.tryParse(value?.trim() ?? '');
                          final min = int.tryParse(
                            controller.repRangeMinController.text.trim(),
                          );
                          if (max == null || max < 1) {
                            return 'Enter max reps (e.g. 20)';
                          }
                          if (min != null && max <= min) {
                            return 'Max must be greater than min';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        keyboardType: TextInputType.number,
                        borderColor: Colors.transparent,
                        labelColor: AppColors.textPrimary,
                        labelText: 'Rest times',
                        hintText: 'eg : 60',
                        controller: controller.restTimeMinController,
                        validator: (value) {
                          final min = int.tryParse(value?.trim() ?? '');
                          if (min == null || min < 1) {
                            return 'Enter min rest in sec (e.g. 60)';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CustomTextField(
                        keyboardType: TextInputType.number,
                        borderColor: Colors.transparent,
                        labelColor: AppColors.textPrimary,
                        labelText: '',
                        hintText: 'eg : 90',
                        controller: controller.restTimeMaxController,
                        validator: (value) {
                          final max = int.tryParse(value?.trim() ?? '');
                          final min = int.tryParse(
                            controller.restTimeMinController.text.trim(),
                          );
                          if (max == null || max < 1) {
                            return 'Enter max rest in sec (e.g. 90)';
                          }
                          if (min != null && max <= min) {
                            return 'Max must be greater than min';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTapDown: (details) {
                    MenuShowHelper.showCustomMenu(
                      context: context,
                      details: details,
                      options: MenuShowHelper.intensityMeasureOptions,
                    ).then((value) {
                      if (value != null) {
                        controller.intensityMeasureController.text = value;
                      }
                    });
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      suffixIcon: Icon(Icons.arrow_drop_down_outlined),
                      borderColor: Colors.transparent,
                      labelColor: AppColors.textPrimary,
                      labelText: 'Intensity measure',
                      hintText: 'Select intensity (e.g. RPE)',
                      controller: controller.intensityMeasureController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select intensity measure';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  labelText: 'Deload frequency',
                  hintText: 'Write here  . . .',
                  controller: controller.deloadFrequencyController,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  labelText: 'Cardio philosophy',
                  hintText: 'Write here  . . .',
                  controller: controller.cardioPhilosophyController,
                ),
                TagAddWidget(
                  labelText: 'Must use exercise',
                  hintText: 'Write here ...',
                  initialTags: controller.mustUseExercises,
                  onTagsChanged: controller.setMustUseExercises,
                ),
                TagAddWidget(
                  labelText: 'Avoid exercises',
                  hintText: 'Write here ...',
                  initialTags: controller.avoidExercises,
                  onTagsChanged: controller.setAvoidExercises,
                ),
                TagAddWidget(
                  labelText: 'Accessory favorites',
                  hintText: 'Write here ...',
                  initialTags: controller.accessoryFavorites,
                  onTagsChanged: controller.setAccessoryFavorites,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  labelText: 'Protein target',
                  hintText: 'Write here  . . .',
                  controller: controller.proteinTargetController,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  labelText: 'Hydration rule',
                  hintText: 'Write here  . . .',
                  controller: controller.hydrationRuleController,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  labelText: 'Maintenance plate',
                  hintText: 'Write here  . . .',
                  controller: controller.maintenancePlateController,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  labelText: 'Weekend strategy',
                  hintText: 'Write here  . . .',
                  controller: controller.weekendStrategyController,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  labelText: 'Consistency method',
                  hintText: 'Write here  . . .',
                  controller: controller.consistencyMethodController,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  labelText: 'Motivation drop response',
                  hintText: 'Write here  . . .',
                  controller: controller.motivationDropResponseController,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  labelText: 'Plateau protocol',
                  hintText: 'Write here  . . .',
                  controller: controller.plateauProtocolController,
                ),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  labelText: 'Deload rules',
                  hintText: 'Write here  . . .',
                  controller: controller.deloadRulesController,
                ),
                DynamicFieldListWidget(
                  title: 'Natural phrases',
                  initialValues: controller.naturalPhrases,
                  onChanged: controller.setNaturalPhrases,
                ),
                TagAddWidget(
                  labelText: 'Never say phrases',
                  hintText: 'Write here ...',
                  initialTags: controller.neverSayPhrases,
                  onTagsChanged: controller.setNeverSayPhrases,
                ),
                GestureDetector(
                  onTapDown: (details) {
                    MenuShowHelper.showCustomMenu(
                      context: context,
                      details: details,
                      options: MenuShowHelper.coachingStyleOptions,
                    ).then((value) {
                      if (value != null) {
                        controller.coachingStyleController.text = value;
                      }
                    });
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      suffixIcon: Icon(Icons.arrow_drop_down_outlined),
                      borderColor: Colors.transparent,
                      labelColor: AppColors.textPrimary,
                      labelText: 'Coaching style',
                      hintText: 'Select coaching style (e.g. balanced)',
                      controller: controller.coachingStyleController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select coaching style';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).asSliver,
      ],
      bottomNavigationBar: Obx(
            () => CustomButton(
          onPressed: controller.submitKnowledgePack,
          isLoading: controller.submitState.isLoading,
          label: 'Submit',
        ),
      ),
    );
  }
}