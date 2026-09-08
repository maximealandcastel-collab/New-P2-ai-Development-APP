import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutMultiSelectField extends StatelessWidget {
  const WorkoutMultiSelectField({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;

  void _toggleSelection(String value) {
    final updated = List<String>.from(selectedValues);
    if (updated.contains(value)) {
      updated.remove(value);
    } else {
      updated.add(value);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          spacing: 10.w,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return CustomContainer(
              width: double.infinity,
              onTap: () => _toggleSelection(option),
              paddingHorizontal: 14.w,
              paddingVertical: 12.h,
              radiusAll: 12.r,
              color:  Colors.white,
              bordersColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              child: CustomText(
                text: StringFormat.formatLabel(option),
                fontSize: 16.sp,
                fontWeight: AppFontWeight.label,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
