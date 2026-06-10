import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/dialog_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class GoalSetupPage extends StatefulWidget {
  const GoalSetupPage({super.key});

  @override
  State<GoalSetupPage> createState() => _GoalSetupPageState();
}

class _GoalSetupPageState extends State<GoalSetupPage> {
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
          text: 'What\'s your goal?',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTapDown: (details) {
            final menu = MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: [
                'Lose Weight',
                'Build Muscle',
                'Improve Endurance',
                'Increase Strength',
                'Improve Flexibility',
                'Enhance Athletic Performance',
                'Maintain Fitness',
                'Stress Relief & Mental Health',
                'Improve Posture',
                'Rehabilitation & Recovery',
              ],
            );
            menu.then((value) {
              if (value != null) primaryGoalController.text = value;
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Primary goal',
              hintText: 'Select primary goal',
              controller: primaryGoalController,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            DateTime tempDate = selectedDate;

            DialogShowHelper.showBottomSheet(
              context,
              title: 'Date of birth',
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
                    initialDateTime: selectedDate,
                    mode: CupertinoDatePickerMode.date,
                    minimumYear: 1900,
                    maximumYear: DateTime.now().year,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              onTapConfirm: () {
                setState(() {
                  selectedDate = tempDate;
                  dateController.text = TimeFormatHelper.formatDate(selectedDate);
                });
              },

            );
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Padding(
                padding: EdgeInsets.all(12.r),
                child: Assets.icons.date.svg(),
              ),
              labelText: 'Date of birth',
              hintText: 'Select date of birth',
              controller: dateController,
            ),
          ),
        ),      ],
    );
  }
}
