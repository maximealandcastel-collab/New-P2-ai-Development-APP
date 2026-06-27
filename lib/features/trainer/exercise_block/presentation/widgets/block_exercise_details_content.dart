import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/data/models/exercise_block_model.dart';
import 'package:pler_to_pler_app/features/trainer/exercise_block/presentation/controllers/create_exercise_block_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class BlockExerciseDetailsContent extends StatelessWidget {
  const BlockExerciseDetailsContent({super.key, required this.exercise});

  final BlockExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    final steps = [...?exercise.steps]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        ..._buildMetaChips(),
        ..._buildWorkoutMetrics(),
        ..._buildTags(),
        ..._buildSubstitutions(),
        ..._buildSteps(steps),
      ],
    );
  }

  List<Widget> _buildMetaChips() {
    final chips = <String>[
      if ((exercise.difficulty ?? '').isNotEmpty)
        StringFormat.formatLabel(exercise.difficulty!),
      if ((exercise.equipment ?? '').isNotEmpty)
        StringFormat.formatLabel(exercise.equipment!),
    ];

    if (chips.isEmpty) return [];

    return [
      Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: chips.map(_metaChip).toList(),
      ),
      SizedBox(height: 14.h),
    ];
  }

  List<Widget> _buildWorkoutMetrics() {
    if (!_hasWorkoutMetrics) return [];

    final metrics = <Widget>[
      if (exercise.sets != null)
        _metricCard(label: 'Sets', value: '${exercise.sets}'),
      if ((exercise.reps ?? '').trim().isNotEmpty)
        _metricCard(label: 'Reps range', value: exercise.reps!.trim()),
      if ((exercise.restTime ?? '').trim().isNotEmpty)
        _metricCard(
          label: 'Rest times',
          value: _formatRestTime(exercise.restTime!.trim()),
        ),
      if ((exercise.rpe ?? '').trim().isNotEmpty)
        _metricCard(label: 'RPE', value: exercise.rpe!.trim()),
    ];

    return [
      LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 10.w) / 2;
          return Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: metrics
                .map((metric) => SizedBox(width: itemWidth, child: metric))
                .toList(),
          );
        },
      ),
      SizedBox(height: 14.h),
    ];
  }

  List<Widget> _buildTags() {
    if (exercise.tags?.isEmpty ?? true) return [];

    return [
      _sectionTitle('Tags'),
      SizedBox(height: 8.h),
      Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: exercise.tags!
            .map((tag) => _detailChip(StringFormat.formatLabel(tag)))
            .toList(),
      ),
      SizedBox(height: 14.h),
    ];
  }

  List<Widget> _buildSubstitutions() {
    if (!_hasSubstitutions) return [];

    return [
      _sectionTitle('Substitutions'),
      SizedBox(height: 8.h),
      ...exercise.substitutions!.entries.map((entry) {
        final label =
            CreateExerciseBlockController.substitutionLabels[entry.key] ??
                StringFormat.formatLabel(entry.key);
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: label,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
              CustomText(
                top: 2.h,
                text: entry.value,
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        );
      }),
    ];
  }

  List<Widget> _buildSteps(List<ExerciseStepModel> steps) {
    if (steps.isEmpty) return [];

    return [
      _sectionTitle('Steps'),
      SizedBox(height: 10.h),
      ...steps.asMap().entries.map(
            (entry) => _buildStepItem(entry.key, entry.value),
          ),
    ];
  }

  Widget _buildStepItem(int index, ExerciseStepModel step) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26.r,
            height: 26.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: CustomText(
              text: '${step.order ?? index + 1}',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: CustomContainer(
              width: double.infinity,
              radiusAll: 12.r,
              paddingHorizontal: 12.w,
              paddingVertical: 10.h,
              color: AppColors.backgroundLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((step.instruction ?? '').trim().isNotEmpty)
                    CustomText(
                      text: step.instruction!.trim(),
                      fontSize: 13.sp,
                      textAlign: TextAlign.start,
                    ),
                  if ((step.tip ?? '').trim().isNotEmpty)
                    CustomText(
                      top: 6.h,
                      text: 'Tip : ${step.tip!.trim()}',
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.start,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return CustomText(
      text: title,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      textAlign: TextAlign.start,
    );
  }

  Widget _metricCard({required String label, required String value}) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            fontSize: 11.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: value,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: CustomText(
        text: label,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _detailChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: CustomText(
        text: label,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        textAlign: TextAlign.start,
      ),
    );
  }

  bool get _hasSubstitutions =>
      exercise.substitutions?.values.any((value) => value.trim().isNotEmpty) ??
      false;

  bool get _hasWorkoutMetrics =>
      exercise.sets != null ||
      (exercise.reps ?? '').trim().isNotEmpty ||
      (exercise.restTime ?? '').trim().isNotEmpty ||
      (exercise.rpe ?? '').trim().isNotEmpty;

  String _formatRestTime(String restTime) {
    final normalized = restTime.toLowerCase();
    if (normalized.endsWith('second') || normalized.endsWith('seconds')) {
      return restTime;
    }

    if (normalized.endsWith('s')) {
      final value = restTime.substring(0, restTime.length - 1).trim();
      if (value.isNotEmpty) return '$value second';
    }

    return '$restTime second';
  }
}
