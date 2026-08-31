import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pler_to_pler_app/core/utils/helpers/photo_picker_helper.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfilePicturePage extends StatefulWidget {
  const ProfilePicturePage({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [


        CustomContainer(
          color: Colors.white,
          height: 148.r,
          width: 148.r,
          shape: BoxShape.circle,
          bordersColor: Colors.grey.shade300,
            paddingAll: _selectedImage == null ? 38.r : 0,
          child: CustomContainer(
            onTap: (){
              PhotoPickerHelper.showPicker(
                context: context,
                onImagePicked: (imageFile) {
                  setState(() => _selectedImage = imageFile);
                },
              );

            },
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            child: _selectedImage == null
                ? Center(child: Assets.icons.camera.svg())
                : ClipOval(
                    child: Image.file(
                      File(_selectedImage!.path),
                      width: 148.r,
                      height: 148.r,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),

        SizedBox(height: 68.h),

        CustomText(
          text: 'Add a profile photo',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        Spacer(),
        CustomButton(
          foregroundColor: Colors.black,
          bordersColor: Colors.grey.shade300,
          backgroundColor: Colors.black.withOpacity(0.04),
          onPressed: widget.onSkip,
          label: 'Maybe later',
        ),
      ],
    );
  }
}
