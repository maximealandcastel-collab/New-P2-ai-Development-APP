import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text.dart';

class ConfirmationDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool isDeleteAction;
  final bool showCancel;

  const ConfirmationDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.confirmLabel,
    required this.onConfirm,
    this.description,
    this.isDeleteAction = false,
    this.showCancel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Stack(
        children: [
          // Close button
          Positioned(
            right: 12.w,
            top: 12.h,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 18.sp, color: Colors.black54),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red Circle Icon Header
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF04438),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 30.sp),
                ),
                SizedBox(height: 20.h),
                // Title
                CustomText(
                  text: title,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  textAlign: TextAlign.center,
                ),
                // Description (Subtitle)
                if (description != null) ...[
                  SizedBox(height: 12.h),
                  CustomText(
                    text: description!,
                    color: Colors.grey,
                    fontSize: 13.sp,
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 28.h),

                // --- Action Buttons ---
                Column(
                  children: [
                    if (showCancel) ...[
                      CustomButton(
                        onPressed: () => Get.back(),
                        label: 'Cancel',
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        bordersColor: Colors.black.withOpacity(0.1),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    CustomButton(
                      onPressed: onConfirm,
                      label: confirmLabel,
                      // If delete action, background is red. Otherwise, background is white (Logout style).
                      backgroundColor: isDeleteAction ? const Color(0xFFF04438) : Colors.white,
                      foregroundColor: isDeleteAction ? Colors.white : Colors.black,
                      bordersColor: isDeleteAction ? null : Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}