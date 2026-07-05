import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_info_row.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RequestInfoSectionCard extends StatelessWidget {
  const RequestInfoSectionCard({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<ProfileInfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return CustomContainer(
      radiusAll: 20.r,
      paddingAll: 16.r,
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
          SizedBox(height: 12.h),
          ...List.generate(rows.length, (index) {
            final row = rows[index];
            return RequestInfoRow(
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
