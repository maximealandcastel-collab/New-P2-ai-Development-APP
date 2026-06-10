import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DynamicFieldListWidget extends StatelessWidget {
  final String title;
  final String hintText;
  final void Function(List<String> values)? onChanged;
  final List<String> initialValues;

  const DynamicFieldListWidget({
    super.key,
    this.title = '',
    this.hintText = 'Write here...',
    this.onChanged,
    this.initialValues = const [],
  });

  @override
  Widget build(BuildContext context) {
    final RxList<TextEditingController> controllers = [
      TextEditingController(),
      ...initialValues.map((e) => TextEditingController(text: e)),
    ].obs;

    void notifyParent() {
      onChanged?.call(
        controllers.skip(1).map((c) => c.text.trim()).toList(),
      );
    }

    void addField() {
      final text = controllers[0].text.trim();
      if (text.isEmpty) return;
      final moved = controllers[0].text;
      controllers[0].clear();
      controllers.insert(1, TextEditingController(text: moved));
      notifyParent();
    }

    void removeField(int index) {
      if (index == 0) return;
      controllers[index].dispose();
      controllers.removeAt(index);
      notifyParent();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          CustomText(
            textAlign: TextAlign.start,
            text: title,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            bottom: 4.h,
          ),
        ],
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            final isFirst = index == 0;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomTextField(
                    validator: (_) => null,
                    controller: controllers[index],
                    hintText: hintText,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: isFirst ? addField : () => removeField(index),
                  child: CustomContainer(
                    marginBottom: 6.h,
                    color: AppColors.colorE6E6E6,
                    radiusAll: 16.r,
                    paddingHorizontal: 10.w,
                    paddingVertical: 12.h,
                    child: isFirst
                        ? Assets.icons.check.svg()
                        : Assets.icons.delete.svg(),
                  ),
                ),
              ],
            );
          },
        )),
      ],
    );
  }
}