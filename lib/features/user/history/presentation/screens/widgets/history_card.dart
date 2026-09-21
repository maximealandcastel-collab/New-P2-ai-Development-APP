import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/widgets/custom_network_image.dart';

class HistoryCard extends StatefulWidget {
  const HistoryCard({
    super.key,
    required this.workout,
    required this.onViewDetails,
    this.onDismiss,
    this.onRetryGeneration,
    this.onAssignedClientsTap,
    this.onClientTap,
  });

  final WorkoutModel workout;
  final VoidCallback onViewDetails;
  final Future<void> Function()? onDismiss;
  final Future<void> Function()? onRetryGeneration;
  final VoidCallback? onAssignedClientsTap;
  final ValueChanged<WorkoutAssignedClient>? onClientTap;

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
    final isEmptyStub = workout.isEmptyGenerationStub;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF1F1F3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateBlock(workout: workout),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: widget.onViewDetails,
                            borderRadius: BorderRadius.circular(6.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Text(
                                _title(workout),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  height: 1.15,
                                  fontWeight: AppFontWeight.section,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget.onDismiss != null)
                          PopupMenuButton<String>(
                            enabled: !_isBusy,
                            tooltip: 'Workout options',
                            color: Colors.white,
                            elevation: 6,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(minWidth: 160.w),
                            icon: Icon(
                              Icons.more_vert_rounded,
                              size: 20.sp,
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
                                    Icon(Icons.delete_outline_rounded, size: 19),
                                    SizedBox(width: 9),
                                    Text('Remove workout'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _subtitle(workout),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              height: 1.2,
                              fontWeight: AppFontWeight.body,
                              color: const Color(0xFF777982),
                            ),
                          ),
                        ),
                        SizedBox(width: 7.w),
                        _StatusPill(status: workout.status ?? ''),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            icon: Icons.fitness_center_rounded,
                            label: 'Main',
                            value: '${mainProgress.$1}/${mainProgress.$2}',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _Metric(
                            icon: Icons.inventory_2_outlined,
                            label: 'Accessories',
                            value:
                                '${accessoryProgress.$1}/${accessoryProgress.$2}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (workout.assignedClients.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _AssignedClientsRow(
              clients: workout.assignedClients,
              onTap: widget.onAssignedClientsTap,
              onClientTap: widget.onClientTap,
            ),
          ],
          if (isEmptyStub && widget.onRetryGeneration != null) ...[
            SizedBox(height: 11.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "This workout didn't generate. Retry or remove it.",
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.3,
                  fontWeight: AppFontWeight.body,
                  color: const Color(0xFF777982),
                ),
              ),
            ),
            SizedBox(height: 11.h),
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
                SizedBox(width: 8.w),
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
            SizedBox(height: 12.h),
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

  String _subtitle(WorkoutModel workout) {
    final specialty = workout.aiPlan?.trainerSpecialty;
    if (specialty != null && specialty.trim().isNotEmpty) {
      return StringFormat.formatLabel(specialty);
    }
    final intensity = workout.workoutIntensity;
    if (intensity != null && intensity.isNotEmpty) {
      return '${StringFormat.formatSelectedList(intensity)} training';
    }
    return 'Personal workout plan';
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.workout});

  final WorkoutModel workout;

  @override
  Widget build(BuildContext context) {
    final raw = workout.date ?? workout.createdAt ?? '';
    final date = DateTime.tryParse(raw)?.toLocal();

    return Container(
      width: 66.w,
      padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 5.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            date == null ? 'DATE' : DateFormat('MMM').format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              height: 1,
              fontWeight: AppFontWeight.label,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            date == null ? '--' : DateFormat('d').format(date),
            style: TextStyle(
              fontSize: 25.sp,
              height: 1,
              fontWeight: AppFontWeight.stat,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            date == null ? '' : DateFormat('yyyy').format(date),
            style: TextStyle(
              fontSize: 10.sp,
              height: 1,
              fontWeight: AppFontWeight.label,
              color: const Color(0xFF555862),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            date == null ? '' : DateFormat('EEE').format(date),
            style: TextStyle(
              fontSize: 9.sp,
              height: 1,
              fontWeight: AppFontWeight.body,
              color: const Color(0xFF9698A0),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.primary),
        SizedBox(width: 6.w),
        Flexible(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.15,
                fontWeight: AppFontWeight.body,
                color: const Color(0xFF777982),
              ),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: AppFontWeight.label),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _AssignedClientsRow extends StatelessWidget {
  const _AssignedClientsRow({
    required this.clients,
    this.onTap,
    this.onClientTap,
  });

  final List<WorkoutAssignedClient> clients;
  final VoidCallback? onTap;
  final ValueChanged<WorkoutAssignedClient>? onClientTap;

  @override
  Widget build(BuildContext context) {
    final visible = clients.take(3).toList();
    final overflow = clients.length - visible.length;

    return Material(
      color: const Color(0xFFF8F8FA),
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(13.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
          child: Row(
            children: [
              Icon(
                Icons.group_outlined,
                size: 17.sp,
                color: const Color(0xFF737680),
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  'Assigned to ${clients.length} '
                  '${clients.length == 1 ? 'client' : 'clients'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: AppFontWeight.body,
                    color: const Color(0xFF656873),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: (visible.length * 22 + 8).w,
                height: 28.r,
                child: Stack(
                  children: [
                    for (var index = 0; index < visible.length; index++)
                      Positioned(
                        left: (index * 19).w,
                        child: GestureDetector(
                          onTap: onClientTap == null
                              ? null
                              : () => onClientTap!(visible[index]),
                          child: _ClientAvatar(client: visible[index]),
                        ),
                      ),
                  ],
                ),
              ),
              if (overflow > 0) ...[
                SizedBox(width: 3.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEE2),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '+$overflow',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: AppFontWeight.label,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              SizedBox(width: 2.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.sp,
                color: const Color(0xFF858791),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientAvatar extends StatelessWidget {
  const _ClientAvatar({required this.client});

  final WorkoutAssignedClient client;

  @override
  Widget build(BuildContext context) {
    return CustomNetworkImage(
      imageUrl: client.profilePicture,
      height: 28.r,
      width: 28.r,
      boxShape: BoxShape.circle,
      backgroundColor: const Color(0xFFFFF1E7),
      border: Border.all(color: Colors.white, width: 1.5),
      fallbackAsset: Center(
        child: Text(
          client.initials,
          style: TextStyle(
            fontSize: 8.5.sp,
            fontWeight: AppFontWeight.label,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isCompleted = normalized == 'completed';
    final isInProgress = normalized == 'in_progress';
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
            : normalized == 'pending'
                ? 'Pending'
                : StringFormat.formatLabel(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5.sp,
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
      height: 39.h,
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
                  Icon(icon, size: 17.sp, color: foreground),
                  SizedBox(width: 6.w),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      height: 1,
                      fontWeight: AppFontWeight.label,
                      color: foreground,
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  SizedBox(width: 8.w),
                  Icon(trailingIcon, size: 16.sp, color: foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
