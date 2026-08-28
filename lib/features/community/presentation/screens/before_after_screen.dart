import 'dart:io';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/community/presentation/controllers/before_after_controller.dart';

class BeforeAfterScreen extends StatelessWidget {
  const BeforeAfterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BeforeAfterController());
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: Get.back,
        ),
        title: Text(
          'Post Progress',
          style: TextStyle(
            color: Colors.black,
            fontWeight: AppFontWeight.section,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share your transformation',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: AppFontWeight.section,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Inspire the community with your before & after.',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 28.h),

              // Photo pickers
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _PhotoPicker(
                          label: 'Before',
                          file: controller.beforeFile.value,
                          onTap: controller.pickBefore,
                          accentColor: Colors.orange,
                        )),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => _PhotoPicker(
                          label: 'After',
                          file: controller.afterFile.value,
                          onTap: controller.pickAfter,
                          accentColor: AppColors.primary,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Caption
              Text(
                'Caption (optional)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: AppFontWeight.label,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                maxLines: 3,
                maxLength: 280,
                decoration: InputDecoration(
                  hintText: 'Describe your journey...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (v) => controller.caption.value = v,
              ),
              SizedBox(height: 24.h),

              // Result message
              Obx(() {
                final msg = controller.submitMessage.value;
                if (msg == null) return const SizedBox.shrink();
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: controller.isSuccess.value
                        ? Colors.green[50]
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: controller.isSuccess.value
                          ? Colors.green[300]!
                          : Colors.red[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.isSuccess.value
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color: controller.isSuccess.value
                            ? Colors.green[700]
                            : Colors.red[700],
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          msg,
                          style: TextStyle(
                            color: controller.isSuccess.value
                                ? Colors.green[800]
                                : Colors.red[800],
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Submit button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed:
                          controller.isSubmitting.value ? null : controller.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: controller.isSubmitting.value
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Post to Community',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: AppFontWeight.section,
                                fontSize: 16.sp,
                              ),
                            ),
                    ),
                  )),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;
  final Color accentColor;

  const _PhotoPicker({
    required this.label,
    required this.file,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: file != null ? accentColor : Colors.grey[200]!,
            width: file != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: file != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(file!, fit: BoxFit.cover),
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: AppFontWeight.section,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6.h,
                    right: 6.w,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(Icons.edit, color: Colors.white, size: 14.sp),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: accentColor,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: AppFontWeight.section,
                      fontSize: 13.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Tap to select',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
      ),
    );
  }
}
