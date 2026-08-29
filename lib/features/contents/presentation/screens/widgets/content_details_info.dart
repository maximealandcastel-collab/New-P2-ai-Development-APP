import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentDetailsInfo extends StatelessWidget {
  const ContentDetailsInfo({super.key, required this.content});

  final ContentModel content;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.primaryBackground,
      radiusAll: 12.r,
      paddingHorizontal: 16.w,
      paddingVertical: 16.h,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: content.title ?? 'Untitled content',
            fontWeight: AppFontWeight.section,
            fontSize: 20.sp,
            textAlign: TextAlign.start,
          ),
          if ((content.exerciseName ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              text: content.exerciseName!,
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              textAlign: TextAlign.start,
            ),
          ],
          SizedBox(height: 12.h),
          _InfoRow(content: content),
          if ((content.description ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 16.h),
            _Section(
              title: 'Description',
              child: CustomText(
                text: content.description!.trim(),
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                textAlign: TextAlign.start,
              ),
            ),
          ],
          if (content.muscleGroups?.isNotEmpty ?? false) ...[
            SizedBox(height: 12.h),
            _Section(
              title: 'Muscle groups',
              child: _TagList(items: content.muscleGroups!),
            ),
          ],
          if (content.equipment?.isNotEmpty ?? false) ...[
            SizedBox(height: 12.h),
            _Section(
              title: 'Equipment',
              child: _TagList(items: content.equipment!),
            ),
          ],
          if (content.tags?.isNotEmpty ?? false) ...[
            SizedBox(height: 12.h),
            _Section(
              title: 'Tags',
              child: _TagList(items: content.tags!),
            ),
          ],
          SizedBox(height: 12.h),
          CustomText(
            text: TimeFormatHelper.getTimeAgo(content.createdAt),
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.content});

  final ContentModel content;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      if (content.durationSeconds != null) _formatDuration(content.durationSeconds!),
      if ((content.difficulty ?? '').isNotEmpty) content.difficulty!,
      if ((content.categoryId?.category ?? '').isNotEmpty) content.categoryId!.category!,
      if (content.viewCount != null) '${content.viewCount} views',
    ];

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: chips.map((label) => ContentDetailChip(label: label)).toList(),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$secs' : '$minutes:$secs';
  }
}

class ContentDetailChip extends StatelessWidget {
  const ContentDetailChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: CustomText(
        text: label,
        fontSize: 12.sp,
        fontWeight: AppFontWeight.label,
        color: AppColors.textPrimary,
        textAlign: TextAlign.start,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: title,
          fontWeight: AppFontWeight.label,
          fontSize: 14.sp,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }
}

class _TagList extends StatelessWidget {
  const _TagList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.map((item) => ContentDetailChip(label: item)).toList(),
    );
  }
}
