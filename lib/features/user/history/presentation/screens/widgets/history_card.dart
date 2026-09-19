import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';

class HistoryCard extends StatefulWidget {
  const HistoryCard({
    super.key,
    required this.workout,
    required this.onViewDetails,
    this.onDismiss,
    this.onRetryGeneration,
  });

  final WorkoutModel workout;
  final VoidCallback onViewDetails;
  final Future<void> Function()? onDismiss;
  final Future<void> Function()? onRetryGeneration;

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  bool _isRemoving = false;
  bool _isRetrying = false;

  bool get _isBusy => _isRemoving || _isRetrying;

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    final plan = workout.aiPlan;
    final mainProgress = workout.exerciseProgress(plan?.mainWork);
    final accessoryProgress = workout.exerciseProgress(plan?.accessories);
    final status = workout.status ?? '';
    final isEmptyStub = workout.isEmptyGenerationStub;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: widget.onViewDetails,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDate(workout),
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.15,
                        fontWeight: AppFontWeight.stat,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 19.sp,
                      color: const Color(0xFF858791),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _StatusPill(status: status),
              if (widget.onDismiss != null) ...[
                SizedBox(width: 2.w),
                PopupMenuButton<String>(
                  enabled: !_isBusy,
                  tooltip: 'Workout options',
                  color: Colors.white,
                  elevation: 8,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 21.sp,
                    color: const Color(0xFF858791),
                  ),
                  onSelected: (value) {
                    if (value == 'remove') _confirmDismiss();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem<String>(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Remove workout'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _title(workout),
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.2,
              fontWeight: AppFontWeight.section,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            'Main: ${mainProgress.$1}/${mainProgress.$2}   •   '
            'Accessories: ${accessoryProgress.$1}/${accessoryProgress.$2}',
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.25,
              fontWeight: AppFontWeight.body,
              color: const Color(0xFF777982),
            ),
          ),
          if (isEmptyStub && widget.onRetryGeneration != null) ...[
            SizedBox(height: 11.h),
            Text(
              "This workout didn't generate. Retry or remove it.",
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.35,
                fontWeight: AppFontWeight.body,
                color: const Color(0xFF777982),
              ),
            ),
            SizedBox(height: 13.h),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _ActionButton(
                    label: _isRetrying ? 'Retrying…' : 'Retry generation',
                    icon: Icons.refresh_rounded,
                    filled: true,
                    onPressed: _isBusy ? null : _retryGeneration,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: _ActionButton(
                    label: _isRemoving ? 'Removing…' : 'Remove',
                    icon: Icons.delete_outline_rounded,
                    filled: false,
                    onPressed: _isBusy ? null : _confirmDismiss,
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: 14.h),
            _ActionButton(
              label: 'View Details',
              trailingIcon: Icons.arrow_forward_rounded,
              filled: true,
              onPressed: widget.onViewDetails,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _retryGeneration() async {
    final action = widget.onRetryGeneration;
    if (action == null || _isBusy) return;
    setState(() => _isRetrying = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isRetrying = false);
    }
  }

  Future<void> _confirmDismiss() async {
    final action = widget.onDismiss;
    if (action == null || _isBusy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Remove this workout?'),
        content: const Text(
          "It'll be removed from your history. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isRemoving = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isRemoving = false);
    }
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
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';
    final color = isCompleted
        ? const Color(0xFF168A3B)
        : isInProgress
            ? const Color(0xFF287DC1)
            : AppColors.primary;
    final background = isCompleted
        ? const Color(0xFFEAF8EE)
        : isInProgress
            ? const Color(0xFFEAF4FD)
            : const Color(0xFFFFF2E7);
    final icon = isCompleted
        ? Icons.check_circle_rounded
        : isInProgress
            ? Icons.show_chart_rounded
            : Icons.hourglass_empty_rounded;
    final label = isCompleted
        ? 'Completed'
        : isInProgress
            ? 'In Progress'
            : status == 'pending'
                ? 'Pending'
                : StringFormat.formatLabel(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1,
              fontWeight: AppFontWeight.label,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final bool filled;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : const Color(0xFF656873);
    return SizedBox(
      height: 40.h,
      width: double.infinity,
      child: Material(
        color: filled ? AppColors.primary : const Color(0xFFF5F5F8),
        borderRadius: BorderRadius.circular(999.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(999.r),
          onTap: onPressed,
          child: Opacity(
            opacity: onPressed == null ? 0.55 : 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18.sp, color: foreground),
                  SizedBox(width: 7.w),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1,
                      fontWeight: AppFontWeight.label,
                      color: foreground,
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  SizedBox(width: 8.w),
                  Icon(trailingIcon, size: 17.sp, color: foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
