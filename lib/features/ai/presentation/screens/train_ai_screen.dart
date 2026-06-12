import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/dynamic_field_list_widget.dart';
import 'package:pler_to_pler_app/widgets/tag_add_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainAiScreen extends StatefulWidget {
  const TrainAiScreen({super.key});

  @override
  State<TrainAiScreen> createState() => _TrainAiScreenState();
}

class _TrainAiScreenState extends State<TrainAiScreen> {
  final List<String> _preferredTags = [];
  final List<String> _exerciseTags = [];
  final List<String> _avoidExercisesTags = [];
  final List<String> _accessoryTags = [];
  final List<String> _intensity = [];
  final List<String> _naturalPhrases = [];
  final List<String> _neverSayPhrases = [];

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Train your personal AI'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            CustomTextField(
              keyboardType: TextInputType.number,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Days per week',
              hintText: 'eg : 4 days',
            ),

            TagAddWidget(
              labelText: 'Preferred Splits',
              hintText: 'Write here ...',
              onTagsChanged: (updatedTags) =>
                  _preferredTags.addAll(updatedTags),
            ),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    keyboardType: TextInputType.number,
                    borderColor: Colors.transparent,
                    labelColor: AppColors.textPrimary,
                    labelText: 'Raps range',
                    hintText: 'min : 8',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomTextField(
                    keyboardType: TextInputType.number,
                    borderColor: Colors.transparent,
                    labelColor: AppColors.textPrimary,
                    labelText: '',
                    hintText: 'max : 20',
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    keyboardType: TextInputType.number,
                    borderColor: Colors.transparent,
                    labelColor: AppColors.textPrimary,
                    labelText: 'Rest times',
                    hintText: 'eg : 30 sec',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomTextField(
                    keyboardType: TextInputType.number,
                    borderColor: Colors.transparent,
                    labelColor: AppColors.textPrimary,
                    labelText: '',
                    hintText: 'eg : 30 sec',
                  ),
                ),
              ],
            ),

            DynamicFieldListWidget(
              onChanged: (value) => _intensity.addAll(value),
              title: 'Intensity measure',
            ),

            CustomTextField(
              keyboardType: TextInputType.number,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Deload frequency',
              hintText: 'Write here  . . .',
            ),

            CustomTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Cardio philosophy',
              hintText: 'Write here  . . .',
            ),

            TagAddWidget(
              labelText: 'Must use exercise',
              hintText: 'Write here ...',
              onTagsChanged: (updatedTags) => _exerciseTags.addAll(updatedTags),
            ),

            TagAddWidget(
              labelText: 'Avoid exercises',
              hintText: 'Write here ...',
              onTagsChanged: (updatedTags) =>
                  _avoidExercisesTags.addAll(updatedTags),
            ),

            TagAddWidget(
              labelText: 'Accessory favorites',
              hintText: 'Write here ...',
              onTagsChanged: (updatedTags) =>
                  _accessoryTags.addAll(updatedTags),
            ),

            CustomTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Protein target',
              hintText: 'Write here  . . .',
            ),

            CustomTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Hydration rule',
              hintText: 'Write here  . . .',
            ),

            CustomTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Maintenance plate',
              hintText: 'Write here  . . .',
            ),

            CustomTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Weekend strategy',
              hintText: 'Write here  . . .',
            ),

            CustomTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Consistency method',
              hintText: 'Write here  . . .',
            ),

            CustomTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Motivation drop response',
              hintText: 'Write here  . . .',
            ),

            CustomTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Plateau protocol',
              hintText: 'Write here  . . .',
            ),

            CustomTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Deload rules',
              hintText: 'Write here  . . .',
            ),

            TagAddWidget(
              onTagsChanged: (value) => _naturalPhrases.addAll(value),
              labelText: 'Natural phrases',
            ),

            TagAddWidget(
              labelText: 'Never say phrases',
              hintText: 'Write here ...',
              onTagsChanged: (updatedTags) =>
                  _neverSayPhrases.addAll(updatedTags),
            ),

            CustomTextField(
              keyboardType: TextInputType.text,
              borderColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              labelText: 'Coaching style',
              hintText: 'Write here  . . .',
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CustomButton(onPressed: () {
            Get.offAllNamed(AppRoute.bottonNavBar);
          }, label: 'Submit'),
        ),
      ),
    );
  }
}
