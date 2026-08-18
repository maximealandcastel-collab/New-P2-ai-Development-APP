import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';


class PhotoPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static void showPicker({
    required BuildContext context,
    required Function(XFile file) onImagePicked,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(text:
              'Select Photo',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    source: ImageSource.camera,
                    onImagePicked: onImagePicked,
                  ),
                  _buildOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    source: ImageSource.gallery,
                    onImagePicked: onImagePicked,
                  ),
                ],
              ),
              // const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // File Picker Method
  static Future<void> pickFile({
    required BuildContext context,
    required Function(PlatformFile file) onFilePicked,
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        onFilePicked(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: 'Error picking file: $e',
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // File Picker with Bottom Sheet (Similar to Photo Picker)
  static void showFilePicker({
    required BuildContext context,
    required Function(PlatformFile file) onFilePicked,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: 'Select File Type',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFileOption(
                    context,
                    icon: Icons.insert_drive_file,
                    label: 'Documents',
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx'],
                    onFilePicked: onFilePicked,
                  ),
                  _buildFileOption(
                    context,
                    icon: Icons.folder,
                    label: 'Any File',
                    type: FileType.any,
                    onFilePicked: onFilePicked,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildFileOption(
      BuildContext context, {
        required IconData icon,
        required String label,
        required FileType type,
        List<String>? allowedExtensions,
        required Function(PlatformFile file) onFilePicked,
      }) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        await pickFile(
          context: context,
          onFilePicked: onFilePicked,
          type: type,
          allowedExtensions: allowedExtensions,
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(16.r),
            child: Icon(icon, size: 30.r, color: AppColors.primary),
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: label,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  static Widget _buildOption(
      BuildContext context, {
        required IconData icon,
        required String label,
        required ImageSource source,
        required Function(XFile file) onImagePicked,
      }) {
    return InkWell(
      onTap: () async {
        final XFile? file = await _picker.pickImage(source: source);
        Navigator.pop(context);
        if (file != null) onImagePicked(file);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            padding:  EdgeInsets.all(16.r),
            child: Icon(icon, size: 30.r, color: AppColors.primary),
          ),
          SizedBox(height: 8.h),
          CustomText(text:
          label,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}