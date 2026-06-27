import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/features/contents/data/models/category_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final CategoryController _controller;
  CategoryModel? _editingCategory;

  bool get _isEditMode => _editingCategory != null;

  @override
  void initState() {
    super.initState();
    _controller = CategoryController.to;
    _editingCategory = Get.arguments as CategoryModel?;
    _controller.setEditCategory(_editingCategory);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _controller.submitCategory(editingCategory: _editingCategory);
  }

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: CustomSliverAppBar(
        title: _isEditMode ? 'Edit category' : 'Add category',
      ),
      bodyList: [
        SizedBox(height: 24.h).asSliver,
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'Category name',
                hintText: 'eg : muscles gain',
                controller: _controller.nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter category name';
                  }
                  return null;
                },
              ),
              CustomTextField(
                contentPaddingVertical: 16.w,
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'Category description',
                hintText: 'Write here . . .',
                minLines: 8,
                maxLines: 8,
                controller: _controller.descriptionController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter category description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ).asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 120.h).asSliver,
      ],
      bottomNavigationBar: Obx(
        () => CustomButton(
          onPressed: _submit,
          isLoading: _controller.submitLoadingState.isLoading,
          label: _isEditMode ? 'Update category' : 'Add category',
          width: double.infinity,
        ),
      ),
    );
  }
}
