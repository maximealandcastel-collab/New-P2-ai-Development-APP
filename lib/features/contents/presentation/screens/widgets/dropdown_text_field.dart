import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DropdownTextField extends StatelessWidget {
  const DropdownTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.options,
    this.validator,
    this.onSelected,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final List<String> options;
  final FormFieldValidator? validator;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        MenuShowHelper.showCustomMenu(
          context: context,
          details: details,
          options: options,
        ).then((value) {
          if (value == null) return;
          controller.text = value;
          onSelected?.call(value);
        });
      },
      child: AbsorbPointer(
        child: CustomTextField(
          suffixIcon: const Icon(Icons.arrow_drop_down_outlined),
          labelText: labelText,
          hintText: hintText,
          controller: controller,
          validator: validator,
        ),
      ),
    );
  }
}
