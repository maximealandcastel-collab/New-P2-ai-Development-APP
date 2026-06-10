import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CertificationsPage extends StatefulWidget {
  const CertificationsPage({super.key});

  @override
  State<CertificationsPage> createState() => _CertificationsPageState();
}

class _CertificationsPageState extends State<CertificationsPage> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  void _addField() {
    final firstText = _controllers[0].text.trim();
    if (firstText.isEmpty) return;

    setState(() {
      final movedValue = _controllers[0].text;
      _controllers[0].clear();
      _controllers.insert(1, TextEditingController(text: movedValue));
    });
  }

  void _removeField(int index) {
    if (index == 0) return;
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
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
            text: 'Add your certifications',
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _controllers.length,
          itemBuilder: (context, index) {
            final isFirst = index == 0;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomTextField(
                    validator: (_) => null,
                    controller: _controllers[index],
                    hintText: 'Write here...',
                  ),
                ),
                SizedBox(width: 8.w),
                if (isFirst)
                  GestureDetector(
                    onTap: _addField,
                    child: CustomContainer(
                      color: AppColors.colorE6E6E6,
                      radiusAll: 16.r,
                      paddingHorizontal: 10.w,
                      paddingVertical: 12.h,
                      child: Assets.icons.check.svg(),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _removeField(index),
                    child: CustomContainer(
                      color: AppColors.colorE6E6E6,
                      radiusAll: 16.r,
                      paddingHorizontal: 10.w,
                      paddingVertical: 12.h,
                      child: Assets.icons.delete.svg(),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}