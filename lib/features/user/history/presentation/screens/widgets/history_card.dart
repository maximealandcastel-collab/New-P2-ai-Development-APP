import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.workout,
    required this.onViewDetails,
  });

  final WorkoutModel workout;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final plan = workout.aiPlan;
    final mainProgress = workout.exerciseProgress(plan?.mainWork);
    final accessoryProgress = workout.exerciseProgress(plan?.accessories);
    final status = workout.status ?? '';
    final isCompleted = status == 'completed';

    return CustomContainer(
      marginBottom: 12.h,
      paddingAll: 14.r,
      color: Colors.white,
      radiusAll: 16.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  textAlign: TextAlign.start,
                  text: _formatDate(workout),
                  fontSize: 16.sp,
                  fontWeight: AppFontWeight.label,
                ),
              ),
              CustomText(
                textAlign: TextAlign.start,
                text: _statusLabel(status),
                right: 6.w,
              ),
              if (isCompleted)
                Icon(Icons.check_circle, color: AppColors.success, size: 20.sp)
              else
                Assets.icons.panding.svg(height: 20.r, width: 20.r),
            ],
          ),
          CustomText(
            textAlign: TextAlign.start,
            text: _title(workout),
            fontWeight: AppFontWeight.emphasis,
            top: 6.h,
          ),
          CustomText(
            textAlign: TextAlign.start,
            text:
                'Main: ${mainProgress.$1}/${mainProgress.$2}   •   Accessories: ${accessoryProgress.$1}/${accessoryProgress.$2}',
            fontWeight: AppFontWeight.emphasis,
            color: AppColors.textSecondary,
            top: 4.h,
            bottom: 12.h,
          ),
          CustomButton(
            height: 36.h,
            fontSize: 14.sp,
            onPressed: onViewDetails,
            label: 'View Details',
          ),
        ],
      ),
    );
  }

  String _formatDate(WorkoutModel workout) {
    final value = workout.date ?? workout.createdAt;
    if (value == null || value.isEmpty) return '--';

    try {
      return TimeFormatHelper.formatDate(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  String _title(WorkoutModel workout) {
    final focusAreas = workout.focusArea;
    if (focusAreas != null && focusAreas.isNotEmpty) {
      return '${StringFormat.formatSelectedList(focusAreas)} Workout';
    }

    final specialty = workout.aiPlan?.trainerSpecialty;
    if (specialty != null && specialty.isNotEmpty) {
      return '${StringFormat.formatLabel(specialty)} Workout';
    }

    return 'Workout Session';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Complete';
      case 'in_progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      default:
        return StringFormat.formatLabel(status.isEmpty ? 'Unknown' : status);
    }
  }
}
