import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TagAddWidget extends StatefulWidget {
  final List<String> initialTags;
  final void Function(List<String> tags)? onTagsChanged;
  final String? hintText;
  final String? labelText;
  final int? maxTags;

  const TagAddWidget({
    super.key,
    this.initialTags = const [],
    this.onTagsChanged,
    this.hintText = 'Write here ...',
    this.maxTags,
    this.labelText,
  });

  @override
  State<TagAddWidget> createState() => _TagAddWidgetState();
}

class _TagAddWidgetState extends State<TagAddWidget> {
  late final TextEditingController _inputController;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _tags = List<String>.from(widget.initialTags);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addTag() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    if (widget.maxTags != null && _tags.length >= widget.maxTags!) return;

    setState(() {
      _tags.add(text);
      _inputController.clear();
    });
    widget.onTagsChanged?.call(List.unmodifiable(_tags));
  }

  void _removeTag(int index) {
    setState(() => _tags.removeAt(index));
    widget.onTagsChanged?.call(List.unmodifiable(_tags));
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _inputController,
                hintText: widget.hintText,
                labelText: widget.labelText,
                labelColor: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _addTag,
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
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: List.generate(_tags.length, (index) {
              return _TagChip(
                key: ValueKey('${_tags[index]}_$index'),
                label: _tags[index],
                onRemove: () => _removeTag(index),
              );
            }),
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({super.key, required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    // Roughly half-width, matching the previous 2-column grid look,
    // without GridView's shrinkWrap layout overhead.
    final width = (MediaQuery.of(context).size.width - 16.w * 2 - 12.w) / 2;

    return SizedBox(
      width: width,
      child: Stack(
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
                    text: label,
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
              onTap: onRemove,
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
      ),
    );
  }
}