import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class MenuDropdownField extends StatelessWidget {
  const MenuDropdownField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    required this.options,
    this.validator,
    this.readOnly = false,
    this.prefixIcon,
  });

  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final List<String> options;
  final FormFieldValidator? validator;
  final bool readOnly;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      return CustomTextField(
        labelText: labelText,
        hintText: hintText,
        controller: controller,
        readOnly: true,
        enabled: false,
        prefixIcon: prefixIcon,
      );
    }

    return GestureDetector(
      onTapDown: (details) {
        MenuShowHelper.showCustomMenu(
          context: context,
          details: details,
          options: options,
        ).then((value) {
          if (value != null) controller.text = value;
        });
      },
      child: AbsorbPointer(
        child: CustomTextField(
          prefixIcon: prefixIcon,
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
