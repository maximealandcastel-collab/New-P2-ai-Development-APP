import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TagAddWidget extends StatelessWidget {
  final List<String> initialTags;
  final void Function(List<String> tags)? onTagsChanged;
  final String? hintText,labelText;
  final int? maxTags;

  const TagAddWidget({
    super.key,
    this.initialTags = const [],
    this.onTagsChanged,
    this.hintText = 'Write here ...',
    this.maxTags, this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController inputController = TextEditingController();
    final RxList<String> tags = List<String>.from(initialTags).obs;

    void addTag() {
      final text = inputController.text.trim();
      if (text.isEmpty) return;
      if (maxTags != null && tags.length >= maxTags!) return;
      tags.add(text);
      inputController.clear();
      onTagsChanged?.call(List.unmodifiable(tags));
    }

    void removeTag(int index) {
      tags.removeAt(index);
      onTagsChanged?.call(List.unmodifiable(tags));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomTextField(
                validator: (_) => null,
                controller: inputController,
                hintText: hintText,
                labelText: labelText,
                labelColor: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: addTag,
              child: CustomContainer(
                marginTop: 14.h,
                color: AppColors.colorE6E6E6,
                radiusAll: 16.r,
                paddingHorizontal: 10.w,
                paddingVertical: 12.h,
                child: Assets.icons.check.svg(),
              ),
            ),
          ],
        ),
        Obx(() => tags.isNotEmpty
            ? Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                childAspectRatio: 3.5,
              ),
              itemCount: tags.length,
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
                              text: tags[index],
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
                        onTap: () => removeTag(index),
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
        )
            : const SizedBox.shrink()),
      ],
    );
  }
}