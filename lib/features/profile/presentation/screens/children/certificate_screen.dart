import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';


class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.r),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 18.r, color: Colors.black),
            ),
          ),
        ),
        centerTitle: true,
        title: CustomText(
          text: 'Certificates',
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Centered Add Button
            GestureDetector(
              onTap: () => _showAddCertificateBottomSheet(context),
              child: CustomContainer(
                height: 100.r,
                width: 100.r,
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.08),
                child: Icon(Icons.add, size: 40.r, color: Colors.black),
              ),
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: 'Add certificates',
              fontSize: 16.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCertificateBottomSheet(BuildContext context) {
    // Local controllers for the sheet
    final TextEditingController shortNameController = TextEditingController();
    final TextEditingController instituteController = TextEditingController();
    final TextEditingController idController = TextEditingController();

    Get.bottomSheet(
      isScrollControlled: true,
      CustomContainer(
        color: Colors.white,
        paddingAll: 20.r,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar and Close Button Row
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32), // Spacer to center title
                  CustomText(
                    text: 'Add a certificate',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: CustomContainer(
                      paddingAll: 4.r,
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                      child: Icon(Icons.close, size: 20.r, color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Form Fields using your CustomTextField
              CustomTextField(
                controller: shortNameController,
                labelText: 'Certificate short name',
                hintText: 'Short name of certificate',
                borderRadio: 12,
                contentPaddingHorizontal: 16.w,
              ),

              CustomTextField(
                controller: instituteController,
                labelText: 'Institute name',
                hintText: 'Name of institute',
                borderRadio: 12,
                contentPaddingHorizontal: 16.w,
              ),

              // Certificate Type Selector (Simplified as TextField for UI matching)
              _buildLabel('Certificate type'),
              CustomContainer(
                radiusAll: 12.r,
                bordersColor: Colors.black.withValues(alpha: 0.16),
                paddingAll: 14.r,
                marginBottom: 16.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Select a certificate type',
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 24.r),
                  ],
                ),
              ),

              CustomTextField(
                controller: idController,
                labelText: 'License / Certificate ID',
                hintText: 'License / Certificate ID number',
                borderRadio: 12,
                contentPaddingHorizontal: 16.w,
              ),

              SizedBox(height: 24.h),

              // Add Service Button (Matching gray state in image)
              CustomButton(
                label: 'Add certificates',
                backgroundColor: Colors.black.withValues(alpha: 0.06),
                foregroundColor: Colors.grey.shade400,
                radius: 12.r,
                onPressed: () {
                  // Logic to save certificate
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

// Helper for labels used outside CustomTextField if needed
  Widget _buildLabel(String text) => CustomText(
    text: text,
    color: AppColors.textSecondary,
    bottom: 8.h,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );


}