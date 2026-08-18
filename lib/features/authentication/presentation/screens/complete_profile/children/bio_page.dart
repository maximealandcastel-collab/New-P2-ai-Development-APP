import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class BioPage extends StatefulWidget {
  const BioPage({super.key});

  @override
  State<BioPage> createState() => _BioPageState();
}

class _BioPageState extends State<BioPage> {

  final TextEditingController bioController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        CustomText(
          text: 'Write about yourself',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          contentPaddingVertical: 8.h,
          contentPaddingHorizontal: 16.w,
          minLines: 5,
          hintText: 'Write something about yourself', controller: bioController,
        ),

      ],
    );
  }
}
