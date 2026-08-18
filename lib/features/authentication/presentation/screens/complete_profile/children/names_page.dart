import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class NamesPage extends StatefulWidget {
  const NamesPage({super.key});

  @override
  State<NamesPage> createState() => _NamesPageState();
}

class _NamesPageState extends State<NamesPage> {

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        CustomText(
          text: 'What’s your name ?',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          prefixIcon: Assets.icons.person.svg(),
          labelText: 'First name',
          hintText: 'Enter your first name', controller: firstNameController,
        ),
        CustomTextField(
          prefixIcon: Assets.icons.person.svg(),
          labelText: 'Last name',
          hintText: 'Enter your last name', controller: lastNameController,
        ),
      ],
    );
  }
}
