import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainingSetupPage extends StatelessWidget {
  const TrainingSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainAiController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Training setup',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
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
      ],
    );
  }
}
