import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/dialog_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class GoalSetupPage extends StatelessWidget {
  const GoalSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;

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
              options: MenuShowHelper.goalOptions,
            );
            menu.then((value) {
              if (value != null) {
                controller.primaryGoalController.text = value;
              }
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Primary goal',
              hintText: 'Select primary goal',
              controller: controller.primaryGoalController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select your primary goal';
                }
                return null;
              },
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            DateTime tempDate = controller.selectedDateOfBirth;
            showModalBottomSheet(
                backgroundColor: Colors.white,
                elevation: 2,
                context: context, builder: (context) {
              return             DialogShowHelper.showBottomSheet(
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
                      initialDateTime: controller.selectedDateOfBirth,
                      mode: CupertinoDatePickerMode.date,
                      minimumYear: 1900,
                      maximumYear: DateTime.now().year,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                onTapConfirm: () {
                  controller.selectedDateOfBirth = tempDate;
                  controller.dateOfBirthController.text =
                      TimeFormatHelper.formatDate(tempDate);
                  Get.back(canPop: true);
                },
              );

            }
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
              controller: controller.dateOfBirthController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select your date of birth';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
