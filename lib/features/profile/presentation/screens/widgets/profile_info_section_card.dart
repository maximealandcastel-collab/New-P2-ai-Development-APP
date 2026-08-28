import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/profile_info_row.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileInfoSectionCard extends StatelessWidget {
  const ProfileInfoSectionCard({
    super.key,
    required this.title,
    required this.onEdit,
    required this.rows,
  });

  final String title;
  final VoidCallback onEdit;
  final List<ProfileInfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 20.r,
      paddingAll: 16.r,
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: title,
                fontWeight: AppFontWeight.section,
                fontSize: 16.sp,
              ),
              GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: CustomContainer(
                  paddingHorizontal: 12.w,
                  paddingVertical: 6.h,
                  radiusAll: 10.r,
                  color: AppColors.primary.withValues(alpha: 0.12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 14.r, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: 'Edit',
                        fontSize: 13.sp,
                        fontWeight: AppFontWeight.label,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...List.generate(rows.length, (index) {
            final row = rows[index];
            return ProfileInfoRow(
              label: row.label,
              value: row.value,
              isLast: index == rows.length - 1,
            );
          }),
        ],
      ),
    );
  }
}
