import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CreateCategoryScreen extends StatelessWidget {
  const CreateCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBarTitle: 'Add category',
      slivers: (context) => [
        SizedBox(height: 24.h).asSliver,
        Form(
          child: Column(
            children: [
              CustomTextField(
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'Category name',
                hintText: 'eg : muscles gain',
              ),
              CustomTextField(
                contentPaddingVertical: 16.w,
                borderColor: Colors.transparent,
                labelColor: Colors.black,
                labelText: 'Category description',
                hintText: 'Write here . . .',
                minLines: 8,
                maxLines: 8,
              ),
            ],
          ),
        ).asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 70.h).asSliver,
      ],
      bottomNavigationBar: CustomButton(
        onPressed: () {},
        label: 'Add category',
        width: double.infinity,
      ),
    );
  }
}
