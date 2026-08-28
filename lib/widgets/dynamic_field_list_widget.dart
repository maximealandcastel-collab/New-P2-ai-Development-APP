import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DynamicFieldListWidget extends StatefulWidget {
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
  State<DynamicFieldListWidget> createState() => _DynamicFieldListWidgetState();
}

class _DynamicFieldListWidgetState extends State<DynamicFieldListWidget> {
  late final TextEditingController _inputController;
  final List<TextEditingController> _fieldControllers = [];

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _fieldControllers.addAll(
      widget.initialValues.map(
        (value) => TextEditingController(text: value),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    for (final controller in _fieldControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _notifyParent() {
    widget.onChanged?.call(
      _fieldControllers.map((controller) => controller.text.trim()).toList(),
    );
  }

  void _addField() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _inputController.clear();
      _fieldControllers.add(TextEditingController(text: text));
    });
    _notifyParent();
  }

  void _removeField(int index) {
    setState(() {
      _fieldControllers[index].dispose();
      _fieldControllers.removeAt(index);
    });
    _notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty) ...[
          CustomText(
            textAlign: TextAlign.start,
            text: widget.title,
            fontSize: 14.sp,
            fontWeight: AppFontWeight.emphasis,
            color: AppColors.textPrimary,
            bottom: 4.h,
          ),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomTextField(
                validator: (_) => null,
                controller: _inputController,
                hintText: widget.hintText,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _addField,
              child: CustomContainer(
                marginBottom: 6.h,
                color: AppColors.colorE6E6E6,
                radiusAll: 16.r,
                paddingHorizontal: 10.w,
                paddingVertical: 12.h,
                child: Assets.icons.check.svg(),
              ),
            ),
          ],
        ),
        ...List.generate(_fieldControllers.length, (index) {
          return Row(
            key: ObjectKey(_fieldControllers[index]),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CustomTextField(
                  validator: (_) => null,
                  controller: _fieldControllers[index],
                  hintText: widget.hintText,
                  onChanged: (_) => _notifyParent(),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => _removeField(index),
                child: CustomContainer(
                  marginBottom: 6.h,
                  color: AppColors.colorE6E6E6,
                  radiusAll: 16.r,
                  paddingHorizontal: 10.w,
                  paddingVertical: 12.h,
                  child: Assets.icons.delete.svg(),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
