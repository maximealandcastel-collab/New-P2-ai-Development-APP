import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerTagsPage extends StatefulWidget {
  const TrainerTagsPage({super.key});

  @override
  State<TrainerTagsPage> createState() => _TrainerTagsPageState();
}

class _TrainerTagsPageState extends State<TrainerTagsPage> {
  final TextEditingController _inputController = TextEditingController();
  final List<String> _tags = [];

  void _addTag() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tags.add(text);
      _inputController.clear();
    });
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CustomText(
            text: 'Add your trainer tags',
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),

        // Input row
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                validator: (_) => null,
                controller: _inputController,
                hintText: 'Write here ...',
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _addTag,
              child: CustomContainer(
                color: AppColors.colorE6E6E6,
                radiusAll: 16.r,
                paddingHorizontal: 10.w,
                paddingVertical: 12.h,
                child: Assets.icons.check.svg(),
              ),
            ),
          ],
        ),

        if (_tags.isNotEmpty) ...[
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              childAspectRatio: 3.5,
            ),
            itemCount: _tags.length,
            itemBuilder: (context, index) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 48.h,
                    child: CustomContainer(
                      marginRight: 10.w,
                      color: Colors.white,
                      radiusAll: 16.r,
                      border: Border.all(color: AppColors.colorE6E6E6),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 16.w,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            text: _tags[index],
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => _removeTag(index),
                      child: CustomContainer(
                        paddingAll: 6.r,
                        shape: BoxShape.circle,
                        color: AppColors.colorE6E6E6,
                        child: Icon(
                          Icons.cancel_outlined,
                          color: AppColors.error,
                          size: 16.r,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
