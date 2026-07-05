import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_profile_chip.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RequestChipSectionCard extends StatelessWidget {
  const RequestChipSectionCard({
    super.key,
    required this.title,
    required this.chips,
    this.chipHighlighted = false,
  });

  final String title;
  final List<String> chips;
  final bool chipHighlighted;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();

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
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: chips
                .map(
                  (chip) => RequestProfileChip(
                    label: chip,
                    highlighted: chipHighlighted,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
