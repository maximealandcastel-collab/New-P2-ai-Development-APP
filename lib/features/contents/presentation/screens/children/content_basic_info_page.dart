import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/complete_profile_page_title.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/create_content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/dropdown_text_field.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentBasicInfoPage extends StatelessWidget {
  const ContentBasicInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CreateContentController.to;
    final categoryControllerRef = CategoryController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CompleteProfilePageTitle(text: 'Content details'),
        SizedBox(height: 16.h),
        Obx(() {
          final options = categoryControllerRef.categories
              .map((item) => item.category ?? '')
              .where((name) => name.isNotEmpty)
              .toList();

          if (options.isEmpty) {
            return CustomTextField(
              readOnly: true,
              labelText: 'Category',
              hintText: 'No active categories found',
              controller: controller.categoryController,
              validator: (value) => 'Please create a category first',
            );
          }

          return DropdownTextField(
            controller: controller.categoryController,
            labelText: 'Category',
            hintText: 'Select category',
            options: options,
            onSelected: (display) {
              final match = categoryControllerRef.categories
                  .firstWhereOrNull((item) => item.category == display);
              if (match?.id != null) {
                controller.onCategorySelected(match!.id!);
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          );
        }),
        CustomTextField(
          labelText: 'Title',
          hintText: 'eg : Perfect Bench Press Form',
          controller: controller.titleController,
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
          controller: controller.descriptionController,
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
