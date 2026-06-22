import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/content_form_constants.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/widgets/dropdown_text_field.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentBasicInfoPage extends StatelessWidget {
  const ContentBasicInfoPage({
    super.key,
    required this.categoryController,
    required this.titleController,
    required this.descriptionController,
    required this.onCategorySelected,
  });

  final TextEditingController categoryController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Content details',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        DropdownTextField(
          controller: categoryController,
          labelText: 'Category',
          hintText: 'Select category',
          options: ContentFormConstants.categoryOptions
              .map((entry) => entry.value)
              .toList(),
          onSelected: onCategorySelected,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
        CustomTextField(
          labelText: 'Title',
          hintText: 'eg : Perfect Bench Press Form',
          controller: titleController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        CustomTextField(
          labelText: 'Description',
          hintText: 'Write here . . .',
          contentPaddingVertical: 16.w,
          contentPaddingHorizontal: 16.w,
          minLines: 6,
          maxLines: 6,
          controller: descriptionController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }
}
