import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_sizes.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextStyle? hintTextStyle;
  final ValueChanged<String>? onChanged;
  final Color? containerColor;
  final Color? containerBorderColor;
  final double? containerBorderWidth;
  final int? maxLines;
  final bool readonly;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final String? prefixIconPath;
  final String? prefixText;
  final TextStyle? prefixTextStyle;
  final Widget? suffixIcon;
  final String? suffixIconPath;
  final String? suffixText;
  final TextStyle? suffixTextStyle;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? focusedErrorBorder;
  final bool showError;
  final Color? errorBorderColor;
  final double? borderRedius;
  final String? Function(String?)? validation;
  final VoidCallback? onClick;

  const CustomTextFormField({
    super.key,
    this.onClick,
    this.validation,
    required this.controller,
    required this.hintText,
    this.hintTextStyle,
    this.onChanged,
    this.containerColor,
    this.containerBorderColor,
    this.containerBorderWidth,
    this.maxLines,
    this.readonly = false,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.prefixIconPath,
    this.prefixText,
    this.prefixTextStyle,
    this.suffixIcon,
    this.suffixIconPath,
    this.suffixText,
    this.suffixTextStyle,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.focusedErrorBorder,
    this.showError = false,
    this.errorBorderColor,
    this.borderRedius,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onClick,
      controller: controller,
      readOnly: readonly,
      obscureText: obscureText,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
      validator: validation,

      // onTapOutside: (PointerDownEvent event) {
      //   FocusManager.instance.primaryFocus?.unfocus();
      // },
      style: GoogleFonts.figtree(
        fontSize: getWidth(16),
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: containerColor ?? AppColors.textWhite,
        contentPadding: EdgeInsets.symmetric(
          vertical: getHeight(16),
          horizontal: getWidth(16),
        ),
        hintText: hintText,
        hintStyle:
            hintTextStyle ??
            GoogleFonts.figtree(
              fontSize: getWidth(15),
              fontWeight: FontWeight.w400,
              color: Color(0xFFd6d6d6),
            ),
        prefixText: prefixText != null ? '$prefixText  ' : null,
        prefixStyle:
            prefixTextStyle ??
            GoogleFonts.figtree(
              fontSize: getWidth(15),
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
        prefixIcon:
            prefixIcon ??
            (prefixIconPath != null
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: getWidth(12)),
                    child: Image.asset(prefixIconPath!, width: getWidth(26)),
                  )
                : null),
        suffixText: suffixText != null ? '  $suffixText' : null,
        suffixStyle:
            suffixTextStyle ??
            GoogleFonts.figtree(
              fontSize: getWidth(15),
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
        suffixIcon:
            suffixIcon ??
            (suffixIconPath != null
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: getWidth(12)),
                    child: Image.asset(suffixIconPath!, width: getWidth(26)),
                  )
                : null),
        border:
            border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRedius ?? 16),
              borderSide: BorderSide(
                color: containerBorderColor ?? AppColors.textFormFieldBorder,
                width: containerBorderWidth ?? 1,
              ),
            ),
        enabledBorder:
            enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRedius ?? 16),
              borderSide: BorderSide(
                color: containerBorderColor ?? AppColors.textFormFieldBorder,
                width: containerBorderWidth ?? 1,
              ),
            ),
        focusedBorder:
            focusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRedius ?? 16),
              borderSide: BorderSide(
                color: AppColors.textFormFieldBorder,
                width: containerBorderWidth ?? 1,
              ),
            ),
        focusedErrorBorder:
            focusedErrorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRedius ?? 16),
              borderSide: BorderSide(
                color: AppColors.error,
                width: containerBorderWidth ?? 1,
              ),
            ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRedius ?? 16),
          borderSide: BorderSide(
            color: AppColors.error,
            width: containerBorderWidth ?? 1,
          ),
        ),
        errorStyle: GoogleFonts.figtree(
          fontSize: getWidth(14),
          fontWeight: FontWeight.w400,
          color: AppColors.error,
        ),
      ),
    );
  }
}
