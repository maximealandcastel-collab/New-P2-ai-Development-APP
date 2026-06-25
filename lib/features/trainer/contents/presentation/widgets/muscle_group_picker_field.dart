import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/dialog_show_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
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

  void _openPicker(BuildContext context) {
    final tempSelected = List<String>.from(selectedValues);

    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DialogShowHelper.showBottomSheet(
              context,
              title: 'Muscle groups',
              buttonLabel: 'Apply',
              onTapConfirm: () {
                onChanged(List<String>.from(tempSelected));
                controller.text =
                    StringFormat.formatSelectedList(tempSelected);
                Get.back();
              },
              content: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 360.h),
                child: SingleChildScrollView(
                  child: Column(
                    children: MenuShowHelper.muscleGroupOptions.map(
                      (value) {
                        final isSelected = tempSelected.contains(value);
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: AppColors.textPrimary,
                          title: CustomText(
                            text: StringFormat.formatLabel(value),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          value: isSelected,
                          onChanged: (checked) {
                            setSheetState(() {
                              if (checked == true) {
                                tempSelected.add(value);
                              } else {
                                tempSelected.remove(value);
                              }
                            });
                          },
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPicker(context),
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
