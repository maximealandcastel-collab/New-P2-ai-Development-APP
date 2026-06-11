import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/dialog_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AdditionalInfoPage extends StatefulWidget {
  const AdditionalInfoPage({super.key});

  @override
  State<AdditionalInfoPage> createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends State<AdditionalInfoPage> {
  final TextEditingController primaryGoalController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    primaryGoalController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'What\'s your additional\ninfo?',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          labelText: 'Preferred name',
          hintText: 'Eg : john',
        ),
        GestureDetector(
          onTapDown: (details) {
            final menu = MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: MenuShowHelper.motivationStyleOptions,
            );
            menu.then((value) {
              if (value != null) primaryGoalController.text = value;
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Motivation style',
              hintText: 'Select motivation',
              controller: primaryGoalController,
            ),
          ),
        ),
      ],
    );
  }
}
