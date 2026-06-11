import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PhysicalInfoPage extends StatefulWidget {
  const PhysicalInfoPage({super.key});

  @override
  State<PhysicalInfoPage> createState() => _PhysicalInfoPageState();
}

class _PhysicalInfoPageState extends State<PhysicalInfoPage> {

  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final fitnessLevelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'What\'s your physical\ninfo ?',
        fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTapDown: (details) {
            final menu = MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: MenuShowHelper.heightOptions,
            );
            menu.then((value) {
              if (value != null) heightController.text = value;
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Your height',
              hintText: 'Eg : 120 cm',
              controller: heightController,
            ),
          ),
        ),

        GestureDetector(
          onTapDown: (details) {
            final menu = MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: MenuShowHelper.weightOptions,
            );
            menu.then((value) {
              if (value != null) weightController.text = value;
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Weight',
              hintText: 'Eg : 64 kg',
              controller: weightController,
            ),
          ),
        ),

        GestureDetector(
          onTapDown: (details) {
            final menu = MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: MenuShowHelper.fitnessLevelOptions,
            );
            menu.then((value) {
              if (value != null) fitnessLevelController.text = value;
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              labelText: 'Fitness level',
              hintText: 'Select fitness level',
              controller: fitnessLevelController,
            ),
          ),
        ),
      ],
    );
  }
}