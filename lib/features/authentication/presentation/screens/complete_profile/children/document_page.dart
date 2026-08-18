import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/helpers/photo_picker_helper.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        CustomText(
          textAlign: TextAlign.start,
          text: 'Upload Tex document',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 24.h),
        Center(
          child: CustomContainer(
            radiusAll: 16.r,
            color: Colors.white,
            height: 148.r,
            width: 148.r,
            bordersColor: Colors.grey.shade300,
            //paddingAll: 38.r,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomContainer(
                  height: 64.r,
                  width: 64.r,
                  onTap: (){
                    PhotoPickerHelper.showFilePicker(context: context,onFilePicked: (PlatformFile file) {
                      print('Picked file: ${file.name}, size: ${file.size} bytes');
                    });
                
                  },
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                  child: Center(
                    child: Assets.icons.file.svg(
                    ),
                  ),
                ),
                CustomText(
                  top: 4.h,
                    color: AppColors.textSecondary,
                    text: 'Only PDF accepted')
              ],
            ),
          ),
        ),
      ],
    );
  }
}
