import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/dynamic_field_list_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class GymInfoPage extends StatefulWidget {
  const GymInfoPage({super.key});

  @override
  State<GymInfoPage> createState() => _GymInfoPageState();
}

class _GymInfoPageState extends State<GymInfoPage> {

  final List<String> _injuries = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CustomText(
            text: 'Add your certifications',
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          labelText: 'Available equipment',
          hintText: 'Eg : 5 feet 10 inch',
        ),

        CustomTextField(
          labelText: 'Weekly training days',
          hintText: 'Eg : 64 kg',
        ),

        DynamicFieldListWidget(
          title: 'Injuries',
          onChanged: (value) => _injuries.addAll(value),
        )
      ],
    );
  }
}