import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class BioPage extends StatelessWidget {
  const BioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileCompleteController.to;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Add your bio ?',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),

        CustomTextField(
          labelText: '@username',
          hintText: 'write here...',
          controller: controller.usernameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your username';
            }
            return null;
          },
        ),
        CustomTextField(
          labelText: 'Description',
          contentPaddingVertical: 8.h,
          contentPaddingHorizontal: 16.w,
          minLines: 7,
          hintText: 'Write something about yourself',
          controller: controller.bioController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your bio description';
            }
            return null;
          },
        ),


      ],
    );
  }
}
