import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileDropdownField extends StatelessWidget {
  const ProfileDropdownField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    required this.options,
    this.validator,
    this.readOnly = false,
  });

  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final List<String> options;
  final FormFieldValidator? validator;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      return CustomTextField(
        labelText: labelText,
        hintText: hintText,
        controller: controller,
        readOnly: true,
        enabled: false,
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
