import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_info_row.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_profile_chip.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RequestFitnessProfileCard extends StatelessWidget {
  const RequestFitnessProfileCard({
    super.key,
    this.fitnessLevel,
    this.bodyMetrics = const [],
    this.trainingChips = const [],
    this.injuryChips = const [],
  });

  final String? fitnessLevel;
  final List<ProfileInfoRowData> bodyMetrics;
  final List<String> trainingChips;
  final List<String> injuryChips;

  bool get _hasContent =>
      fitnessLevel != null ||
      bodyMetrics.isNotEmpty ||
      trainingChips.isNotEmpty ||
      injuryChips.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();

    return CustomContainer(
      radiusAll: 20.r,
      paddingAll: 16.r,
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fitnessLevel != null) ...[
            _buildSectionTitle('Fitness Level'),
            SizedBox(height: 12.h),
            RequestProfileChip(label: fitnessLevel!, highlighted: true),
            if (bodyMetrics.isNotEmpty ||
                trainingChips.isNotEmpty ||
                injuryChips.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Divider(color: AppColors.colorE6E6E6, height: 1.h),
              SizedBox(height: 16.h),
            ],
          ],
          if (bodyMetrics.isNotEmpty) ...[
            _buildSectionTitle('Body Metrics'),
            SizedBox(height: 12.h),
            ...List.generate(bodyMetrics.length, (index) {
              final row = bodyMetrics[index];
              return RequestInfoRow(
                label: row.label,
                value: row.value,
                isLast: index == bodyMetrics.length - 1,
              );
            }),
            if (trainingChips.isNotEmpty || injuryChips.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Divider(color: AppColors.colorE6E6E6, height: 1.h),
              SizedBox(height: 16.h),
            ],
          ],
          if (trainingChips.isNotEmpty) ...[
            _buildSectionTitle('Training Preferences'),
            SizedBox(height: 12.h),
            _buildChipWrap(trainingChips),
            if (injuryChips.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Divider(color: AppColors.colorE6E6E6, height: 1.h),
              SizedBox(height: 16.h),
            ],
          ],
          if (injuryChips.isNotEmpty) ...[
            _buildSectionTitle('Injuries'),
            SizedBox(height: 12.h),
            _buildChipWrap(injuryChips),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return CustomText(
      text: title,
      fontWeight: AppFontWeight.title,
      fontSize: 16.sp,
    );
  }

  Widget _buildChipWrap(List<String> chips) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: chips.map((chip) => RequestProfileChip(label: chip)).toList(),
    );
  }
}
