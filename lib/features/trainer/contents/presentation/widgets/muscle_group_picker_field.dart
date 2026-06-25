import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/fonts.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class MuscleGroupPickerField extends StatelessWidget {
  const MuscleGroupPickerField({
    super.key,
    required this.controller,
    required this.selectedValues,
    required this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final FormFieldValidator? validator;

  List<String> get _displayOptions =>
      MenuShowHelper.muscleGroupOptions.map(StringFormat.formatLabel).toList();

  String? _backendValue(String display) {
    for (final option in MenuShowHelper.muscleGroupOptions) {
      if (StringFormat.formatLabel(option) == display) return option;
    }
    return null;
  }

  void _toggleSelection(String display) {
    final backend = _backendValue(display);
    if (backend == null) return;

    final updated = List<String>.from(selectedValues);
    if (updated.contains(backend)) {
      updated.remove(backend);
    } else {
      updated.add(backend);
    }

    onChanged(updated);
    controller.text = StringFormat.formatSelectedList(updated);
  }

  Future<void> _openDropdown(
    BuildContext context,
    TapDownDetails details,
  ) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final tapPosition = details.globalPosition;

    final selected = await showMenu<String>(
      context: context,
      color: Colors.white,
      constraints: BoxConstraints(
        maxHeight: 280.h,
        minWidth: 160.w,
        maxWidth: 220.w,
      ),
      position: RelativeRect.fromRect(
        Rect.fromPoints(tapPosition, tapPosition),
        Offset.zero & overlay.size,
      ),
      items: _displayOptions.map((option) {
        final backend = _backendValue(option);
        final isSelected =
            backend != null && selectedValues.contains(backend);

        return PopupMenuItem<String>(
          height: 38.h,
          value: option,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                    fontFamily: FontFamily.figtree,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
            ],
          ),
        );
      }).toList(),
    );

    if (selected != null) _toggleSelection(selected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _openDropdown(context, details),
      child: AbsorbPointer(
        child: CustomTextField(
          suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
          labelText: 'Muscle groups',
          hintText: 'Select muscle groups',
          controller: controller,
          validator: validator,
        ),
      ),
    );
  }
}
