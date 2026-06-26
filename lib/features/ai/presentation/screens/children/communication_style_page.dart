import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CommunicationStylePage extends StatelessWidget {
  const CommunicationStylePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrainAiController.to;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Communication style',
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        TagAddWidget(
          labelText: 'Never say phrases',
          hintText: 'Write here ...',
          initialTags: controller.neverSayPhrases,
          onTagsChanged: controller.setNeverSayPhrases,
        ),
        GestureDetector(
          onTapDown: (details) {
            MenuShowHelper.showCustomMenu(
              context: context,
              details: details,
              options: HelperData.coachingStyleOptions,
            ).then((value) {
              if (value != null) {
                controller.coachingStyleController.text = value;
              }
            });
          },
          child: AbsorbPointer(
            child: CustomTextField(
              suffixIcon: Icon(Icons.arrow_drop_down_outlined),
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Coaching style',
              hintText: 'Select coaching style (e.g. balanced)',
              controller: controller.coachingStyleController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select coaching style';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
