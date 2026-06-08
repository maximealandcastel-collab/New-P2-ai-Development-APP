import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';


class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool? isObscureText;
  final String? obscure;
  final Color? filColor;
  final Color? borderColor;
  final Color? hintextColor;
  final Widget? prefixIcon;
  final String? labelText;
  final String? hintText;
  final double? contentPaddingHorizontal;
  final double? contentPaddingVertical;
  final double? hintextSize;
  final Widget? suffixIcon;
  final FormFieldValidator? validator;
  final bool isPassword;
  final bool? isEmail;
  final bool? readOnly;
  final double? borderRadio;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final Color? cursorColor;
  final int? maxLength;
  final int? maxLines;
  final bool? enabled;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool isDatePicker;
  final String? fontFamily;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatter;
  final int? minLines;
  final InputBorder? border;

  const CustomTextField(
      {super.key,
      this.contentPaddingHorizontal,
      this.contentPaddingVertical,
      this.hintText,
      this.prefixIcon,
      this.suffixIcon,
      this.validator,
      this.hintextColor,
      this.borderColor,
      this.isEmail = false,
      required this.controller,
      this.keyboardType = TextInputType.text,
      this.isObscureText = false,
      this.obscure = '*',
      this.filColor,
      this.hintextSize,
      this.labelText,
      this.isPassword = false,
      this.readOnly = false,
      this.borderRadio,
      this.onTap,
      this.onChanged,
      this.cursorColor,
      this.maxLength,
      this.enabled,
      this.focusNode,
      this.autofocus = false,
      this.isDatePicker = false,
      this.fontFamily,
      this.textInputAction,
      this.inputFormatter,
      this.minLines, this.maxLines, this.border});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  void toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          CustomText(
            text: widget.labelText ?? '',
            fontName:'Figtree',
            color: Color(0xFF0B0D10),
            bottom: 4.h,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        SizedBox(
          height: 4.h,
        ),
        TextFormField(
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onTap: () {
            if (widget.isDatePicker) {
             // _selectDate(context);
            } else {
              widget.onTap?.call();
            }
          },
          readOnly: widget.readOnly!,
          controller: widget.controller ?? TextEditingController(),
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatter,
          textInputAction: widget.textInputAction,
          obscuringCharacter: widget.obscure!,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          minLines: widget.isPassword ? 1 : (widget.minLines ?? 1),
          maxLines: widget.isPassword ? 1 : (widget.maxLines ?? 8),


          validator: widget.validator ??
              (value) {
                if (widget.isEmail == false) {
                  if (value!.isEmpty) {
                    return "Please  ${widget.hintText!.toLowerCase()}";
                  } else if (widget.isPassword) {
                    if (value.isEmpty) {
                      return "Please  ${widget.hintText!.toLowerCase()}";
                    } else if (value.length < 8) {
                      return "Password: 8 characters min!";
                    }
                  }
                } else {
                  // bool data = AppConstants.emailValidate.hasMatch(value!);
                  // if (value.isEmpty) {
                  //   return "Please  ${widget.hintText!.toLowerCase()}";
                  // } else if (!data) {
                  //   return "Please check your email!";
                  // }
                }
                return null;
              },

          cursorColor: widget.cursorColor ?? AppColors.textSecondary,
          obscureText: widget.isPassword ? obscureText : false,
          style: TextStyle(
              color: widget.hintextColor ?? AppColors.textSecondary,
              fontSize: widget.hintextSize ?? 14.h,
              fontFamily: widget.fontFamily),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.contentPaddingHorizontal ?? 0.w,
                  vertical: widget.contentPaddingVertical ?? 0.h),
              fillColor: widget.filColor ?? Colors.white,
              filled: true,
              prefixIcon: widget.prefixIcon != null ? Padding(
                padding:  EdgeInsets.symmetric(horizontal: 10.w),
                child: widget.prefixIcon,
              ) : null,
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: toggle,
                      child: _suffixIcon(obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                    )
                  : widget.suffixIcon,
              prefixIconConstraints: BoxConstraints(minHeight: 24.w, minWidth: 24.w),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontFamily: widget.fontFamily ?? 'Figtree',
                  color: widget.hintextColor ?? Colors.black.withOpacity(0.16),
                  fontSize: widget.hintextSize ?? 14.h,
                  fontWeight: FontWeight.w400),
              focusedBorder: widget.border ?? focusedBorder(),
              enabledBorder: widget.border ?? enabledBorder(),
              errorBorder: widget.border ?? errorBorder(),
              border: widget.border ??  focusedBorder(),
              focusedErrorBorder: widget.border ?? errorBorder(),
              errorStyle:
                  TextStyle(fontSize: 12.h, fontWeight: FontWeight.w400)),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _suffixIcon(IconData icon) {
    return Padding(
        padding: const EdgeInsets.all(0),
        child: Icon(icon, color: AppColors.textSecondary,size: 20.r));
  }

  OutlineInputBorder focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadio?.r ?? 16.r),
      borderSide: BorderSide(
          width: 1, color: widget.borderColor ?? Colors.black.withOpacity(0.16)),
    );
  }

  OutlineInputBorder enabledBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadio?.r ?? 16.r),
      borderSide: BorderSide(
          width: 1, color: widget.borderColor ?? Colors.black.withOpacity(0.16)),
    );
  }

  OutlineInputBorder errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadio?.r ?? 16.r),
      borderSide:
      BorderSide(color: widget.borderColor ?? Colors.red, width: 1),
    );
  }
}
