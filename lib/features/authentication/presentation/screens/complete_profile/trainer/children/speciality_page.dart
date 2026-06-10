import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SpecialityPage extends StatefulWidget {
  const SpecialityPage({super.key});

  @override
  State<SpecialityPage> createState() => _SpecialityPageState();
}

class _SpecialityPageState extends State<SpecialityPage> {

  final TextEditingController specialityController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Add your speciality',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          hintText: 'Write here', controller: specialityController,
        ),

      ],
    );
  }
}
