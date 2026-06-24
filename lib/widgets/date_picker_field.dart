import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/dialog_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.controller,
    required this.initialDate,
    required this.onDateChanged,
    this.labelText = 'Date of birth',
    this.hintText = 'Select date of birth',
    this.validator,
  });

  final TextEditingController controller;
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;
  final String labelText;
  final String hintText;
  final FormFieldValidator? validator;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        DateTime tempDate = initialDate;
        showModalBottomSheet(
          backgroundColor: Colors.white,
          elevation: 2,
          context: context,
          builder: (sheetContext) {
            return DialogShowHelper.showBottomSheet(
              sheetContext,
              title: labelText,
              content: SizedBox(
                height: 186.h,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    itemExtent: 32.0,
                    onDateTimeChanged: (DateTime newDate) {
                      tempDate = newDate;
                    },
                    initialDateTime: initialDate,
                    mode: CupertinoDatePickerMode.date,
                    minimumYear: 1900,
                    maximumYear: DateTime.now().year,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              onTapConfirm: () {
                onDateChanged(tempDate);
                controller.text = TimeFormatHelper.formatDate(tempDate);
                Get.back(canPop: true);
              },
            );
          },
        );
      },
      child: AbsorbPointer(
        child: CustomTextField(
          suffixIcon: Padding(
            padding: EdgeInsets.all(12.r),
            child: Assets.icons.date.svg(),
          ),
          labelText: labelText,
          hintText: hintText,
          controller: controller,
          validator: validator,
        ),
      ),
    );
  }
}
