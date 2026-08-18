import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/helpers/photo_picker_helper.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfilePicturePage extends StatefulWidget {
  const ProfilePicturePage({super.key});

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {

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
          paddingAll: 38.r,
          child: CustomContainer(
            onTap: (){
              PhotoPickerHelper.showPicker(context: context, onImagePicked: (imageFile){
                // Handle the picked image file

              });

            },
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            child: Center(
              child: Assets.icons.camera.svg(
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
          onPressed: () {

          },
          label: 'Maybe later',
        ),
      ],
    );
  }
}
