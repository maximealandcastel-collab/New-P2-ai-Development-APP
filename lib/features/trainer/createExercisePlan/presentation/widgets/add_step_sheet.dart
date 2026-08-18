import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/custom_text.dart';
import '../../../../../widgets/custom_text_field.dart';

import 'package:flutter/cupertino.dart';

class AddStepSheet extends StatefulWidget {
  const AddStepSheet({super.key});

  @override
  State<AddStepSheet> createState() => _AddStepSheetState();
}

class _AddStepSheetState extends State<AddStepSheet> {
  final TextEditingController _stepController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();

  // State for the selected time
  Duration selectedDuration = const Duration(minutes: 2);

  // Helper to format duration to "M:SS min"
  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString();
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds min";
  }

  // Function to show the Roller/Cupertino Time Picker
  void _showTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300.h,
        padding: EdgeInsets.only(top: 6.h),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            // Header with Reset and Done
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => selectedDuration = Duration.zero);
                      Navigator.pop(context);
                    },
                    child: CustomText(text: "Reset", color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: CustomText(text: "Done", color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),
            // The actual Roller Picker
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.ms, // Minutes and Seconds
                initialTimerDuration: selectedDuration,
                onTimerDurationChanged: (Duration newDuration) {
                  setState(() => selectedDuration = newDuration);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle & Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    CustomText(text: "Add step", fontSize: 18.sp, fontWeight: FontWeight.bold),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: CircleAvatar(
                        radius: 15.r,
                        backgroundColor: Colors.black.withOpacity(0.05),
                        child: Icon(Icons.close, size: 16.sp, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          _buildLabel("Step"),
          CustomTextField(hintText: "Name of the step", controller: _stepController),
          SizedBox(height: 16.h),

          _buildLabel("What to do"),
          CustomTextField(
            hintText: "Describe about your video",
            maxLines: 4,
            prefixIcon: const Icon(Icons.auto_awesome),
            controller: _videoController,
          ),
          SizedBox(height: 16.h),

          // Time Picker Trigger
          GestureDetector(
            onTap: _showTimePicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(text: "Time", fontWeight: FontWeight.bold),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    // Displays the dynamic time
                    child: CustomText(
                        text: _formatDuration(selectedDuration),
                        fontSize: 14.sp
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          CustomButton(
            onPressed: () => Get.back(),
            label: "Add step",
            // Button lights up if name is entered
            backgroundColor: _stepController.text.isNotEmpty ? Colors.orange : Colors.black.withOpacity(0.05),
            foregroundColor: _stepController.text.isNotEmpty ? Colors.white : Colors.grey,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return CustomText(
      text: text,
      fontSize: 14.sp,
      color: Colors.grey,
      bottom: 8.h,
    );
  }
}