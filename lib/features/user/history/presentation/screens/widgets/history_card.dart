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
    this.onDismiss,
    this.onRetryGeneration,
  });

  final WorkoutModel workout;
  final VoidCallback onViewDetails;

  /// "X out" this workout so it stops cluttering the feed.
  final VoidCallback? onDismiss;

  /// Re-run generation for a workout stuck as an empty "0/0" stub.
  final VoidCallback? onRetryGeneration;

  @override
  Widget build(BuildContext context) {
    final plan = workout.aiPlan;
    final mainProgress = workout.exerciseProgress(plan?.mainWork);
    final accessoryProgress = workout.exerciseProgress(plan?.accessories);
    final status = workout.status ?? '';
    final isCompleted = status == 'completed';
    final isEmptyStub = workout.isEmptyGenerationStub;

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
              if (onDismiss != null) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _confirmDismiss(context),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
            bottom: isEmptyStub && onRetryGeneration != null ? 4.h : 12.h,
          ),
          if (isEmptyStub && onRetryGeneration != null) ...[
            CustomText(
              textAlign: TextAlign.start,
              text: "This workout didn't generate. Retry or remove it.",
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              bottom: 10.h,
            ),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    height: 36.h,
                    fontSize: 14.sp,
                    onPressed: onRetryGeneration,
                    label: 'Retry generation',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomButton(
                    height: 36.h,
                    fontSize: 14.sp,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textSecondary,
                    bordersColor: AppColors.textSecondary,
                    onPressed: () => _confirmDismiss(context),
                    label: 'Remove',
                  ),
                ),
              ],
            ),
          ] else
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

  void _confirmDismiss(BuildContext context) {
    if (onDismiss == null) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this workout?'),
        content: const Text(
          "It'll be removed from your history. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDismiss!();
            },
            child: const Text('Remove'),
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
