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
        SizedBox(height: 14.h),
        ..._buildMetaChips(),
        ..._buildWorkoutMetrics(),
        ..._buildTags(),
        ..._buildSubstitutions(),
        ..._buildSteps(steps),
      ],
    );
  }

  List<Widget> _buildMetaChips() {
    final chips = <Widget>[
      if ((exercise.difficulty ?? '').isNotEmpty)
        _metaChip(
          icon: Icons.signal_cellular_alt_rounded,
          label: StringFormat.formatLabel(exercise.difficulty!),
        ),
      if ((exercise.equipment ?? '').isNotEmpty)
        _metaChip(
          icon: Icons.sports_gymnastics_rounded,
          label: StringFormat.formatLabel(exercise.equipment!),
        ),
    ];

    if (chips.isEmpty) return [];

    return [
      Wrap(spacing: 8.w, runSpacing: 8.h, children: chips),
      SizedBox(height: 14.h),
    ];
  }

  List<Widget> _buildWorkoutMetrics() {
    if (!_hasWorkoutMetrics) return [];

    final metrics = <Widget>[
      if (exercise.sets != null)
        _metricCard(
          icon: Icons.layers_outlined,
          label: 'Sets',
          value: '${exercise.sets}',
          color: AppColors.primary,
        ),
      if ((exercise.reps ?? '').trim().isNotEmpty)
        _metricCard(
          icon: Icons.repeat_rounded,
          label: 'Reps range',
          value: exercise.reps!.trim(),
          color: AppColors.info,
        ),
      if ((exercise.restTime ?? '').trim().isNotEmpty)
        _metricCard(
          icon: Icons.timer_outlined,
          label: 'Rest times',
          value: _formatRestTime(exercise.restTime!.trim()),
          color: AppColors.success,
        ),
      if ((exercise.rpe ?? '').trim().isNotEmpty)
        _metricCard(
          icon: Icons.speed_rounded,
          label: 'RPE',
          value: exercise.rpe!.trim(),
          color: const Color(0xFF8B5CF6),
        ),
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
      SizedBox(height: 16.h),
    ];
  }

  List<Widget> _buildTags() {
    if (exercise.tags?.isEmpty ?? true) return [];

    return [
      _sectionTitle(Icons.sell_outlined, 'Tags'),
      SizedBox(height: 10.h),
      Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: exercise.tags!
            .map((tag) => _detailChip(StringFormat.formatLabel(tag)))
            .toList(),
      ),
      SizedBox(height: 16.h),
    ];
  }

  List<Widget> _buildSubstitutions() {
    if (!_hasSubstitutions) return [];

    return [
      _sectionTitle(Icons.swap_horiz_rounded, 'Substitutions'),
      SizedBox(height: 10.h),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.subdirectory_arrow_right_rounded,
                size: 16.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
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
              ),
            ],
          ),
        );
      }),
      SizedBox(height: 8.h),
    ];
  }

  List<Widget> _buildSteps(List<ExerciseStepModel> steps) {
    if (steps.isEmpty) return [];

    return [
      _sectionTitle(Icons.format_list_numbered_rounded, 'Steps'),
      SizedBox(height: 12.h),
      ...steps.asMap().entries.map(
            (entry) => _buildStepItem(
              index: entry.key,
              step: entry.value,
              isLast: entry.key == steps.length - 1,
            ),
          ),
    ];
  }

  Widget _buildStepItem({
    required int index,
    required ExerciseStepModel step,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: CustomText(
                  text: '${step.order ?? index + 1}',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  textAlign: TextAlign.center,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: AppColors.colorE6E6E6,
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((step.instruction ?? '').trim().isNotEmpty)
                    CustomText(
                      text: step.instruction!.trim(),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.start,
                    ),
                  if ((step.tip ?? '').trim().isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: CustomText(
                              text: step.tip!.trim(),
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.textPrimary),
        SizedBox(width: 8.w),
        CustomText(
          text: title,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            radiusAll: 10.r,
            paddingAll: 6.r,
            color: color.withValues(alpha: 0.15),
            child: Icon(icon, size: 16.sp, color: color),
          ),
          SizedBox(height: 10.h),
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
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _metaChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 6.w),
          CustomText(
            text: label,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _detailChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: CustomText(
        text: label,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
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
