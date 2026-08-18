import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../core/utils/helpers/photo_picker_helper.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/custom_container.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../../../../../widgets/custom_text.dart';

import 'package:get/get.dart';

import '../../../../../widgets/custom_text_field.dart';
import 'add_step_sheet.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddExerciseBlockScreen extends StatefulWidget {
  const AddExerciseBlockScreen({super.key});

  @override
  State<AddExerciseBlockScreen> createState() => _AddExerciseBlockScreenState();
}

class _AddExerciseBlockScreenState extends State<AddExerciseBlockScreen> {
  final TextEditingController _nameController = TextEditingController();

  // State variables
  File? _selectedImage;
  int _repeatCount = 2;
  // This would typically be a model class, using Map for simplicity here
  final List<Map<String, String>> _steps = [
    {"name": "Arm Circles", "duration": "30 seconds"},
    {"name": "Torso Twists", "duration": "30 seconds"},
    {"name": "Wall Push-Ups", "duration": "30 seconds"},
    {"name": "Jumping Jacks", "duration": "30 seconds"},
  ];

  void _pickImage() {
    PhotoPickerHelper.showPicker(
      context: context,
      onImagePicked: (XFile file) {
        setState(() {
          _selectedImage = File(file.path);
        });
      },
    );
  }

  void _showRepeatPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250.h,
        color: Colors.white,
        child: Column(
          children: [
            _buildPickerHeader(),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40.h,
                onSelectedItemChanged: (index) {
                  setState(() => _repeatCount = index + 1);
                },
                children: List.generate(10, (i) => Center(child: Text("${i + 1}"))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerHeader() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(onTap: () => Get.back(), child: const CustomText(text: 'Cancel',color: AppColors.primary,)),
          GestureDetector(onTap: () => Get.back(), child:  CustomText(text: 'Done',color : AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: 'Add exercise block',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.r,
                child: Icon(Icons.delete, color: Colors.red, size: 22.sp),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Cover Photo Section ---
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: _selectedImage == null
                    ? _buildImagePlaceholder()
                    : _buildSelectedImagePreview(),
              ),
            ),
            SizedBox(height: 24.h),

            // --- Exercise Name Field ---
            _buildLabel("Exercise name"),
            CustomTextField(
              hintText: "Name of the exercise",
              controller: _nameController,
            ),
            SizedBox(height: 16.h),

            // --- Repeat Step Row ---
            GestureDetector(
              onTap: _showRepeatPicker,
              child: CustomContainer(
                paddingAll: 12.r,
                radiusAll: 12.r,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(text: "Repeat step", fontWeight: FontWeight.w600),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: CustomText(text: "$_repeatCount time", fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // --- Steps List ---
            CustomText(text: "Steps", fontSize: 18.sp, fontWeight: FontWeight.bold, bottom: 12.h),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) => _buildStepTile(_steps[index]),
            ),

            SizedBox(height: 12.h),
            _buildAddStepButton(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CustomButton(
            onPressed: () {},
            label: "Add exercise block",
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 150.w,
      height: 150.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, color: Colors.grey, size: 40.sp),
          SizedBox(height: 8.h),
          CustomText(text: "Add a cover photo", fontSize: 12.sp, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSelectedImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Image.file(_selectedImage!, width: 150.w, height: 150.w, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8.r,
          right: 8.r,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImage = null),
            child: CircleAvatar(
              radius: 12.r,
              backgroundColor: Colors.white,
              child: Icon(Icons.delete, size: 14.sp, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepTile(Map<String, String> step) {
    return CustomContainer(
      paddingAll: 16.r,
      radiusAll: 16.r,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: step["name"]!, fontWeight: FontWeight.bold, fontSize: 14.sp),
              CustomText(text: step["duration"]!, color: Colors.grey, fontSize: 12.sp),
            ],
          ),
          Icon(Icons.more_vert, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildAddStepButton() {
    return GestureDetector(
      onTap: () => Get.bottomSheet(const AddStepSheet(), isScrollControlled: true),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 14.r,
              backgroundColor: Colors.black.withOpacity(0.05),
              child: Icon(Icons.add, size: 18.sp, color: Colors.black),
            ),
            SizedBox(width: 12.w),
            CustomText(text: "Add Step", fontWeight: FontWeight.w600),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return CustomText(text: text, fontSize: 14.sp, color: Colors.grey, bottom: 8.h);
  }
}