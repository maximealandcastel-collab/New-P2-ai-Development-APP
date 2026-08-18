
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/utils/constants/app_colors.dart';

import 'package:pler_to_pler_app/widgets/widgets.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  // Dummy list to simulate added services
  // In a real app, this would come from your BeauticianStoreService
  final List<Map<String, String>> services = [
    {
      'title': 'AME',
      'subtitle': 'Physical center AC institute',
      'type': 'Physical therapist',
      'phone': '254-584-874-0025'
    },
    {
      'title': 'AME',
      'subtitle': 'Physical center AC institute',
      'type': 'Physical therapist',
      'phone': '254-584-874-0025'
    },
  ];

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
          text: 'Services',
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      // Switch between empty state and list view based on data
      body: services.isEmpty
          ? _buildEmptyState(context)
          : _buildServiceList(context),
    );
  }

  // Initial UI when no services exist
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showAddServiceBottomSheet(context),
            child: CustomContainer(
              height: 100.r,
              width: 100.r,
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.08),
              child: Icon(Icons.add, size: 40.r, color: Colors.black),
            ),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: 'Add services',
            fontSize: 16.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  // UI after services are added
  Widget _buildServiceList(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        children: [
          // Generate cards for each service
          ...services.map((service) => _buildServiceCard(service)),

          SizedBox(height: 8.h),

          // The "Dashed" style Add Service button at the bottom
          GestureDetector(
            onTap: () => _showAddServiceBottomSheet(context),
            child: CustomContainer(
              height: 58.h,
              width: double.infinity,
              radiusAll: 12.r,
              color: Colors.transparent,
              bordersColor: Colors.black.withOpacity(0.1), // Suggest using dotted_border package for exact look
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomContainer(
                    height: 24.r, width: 24.r,
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.08),
                    child: Icon(Icons.add, size: 16.r, color: Colors.black),
                  ),
                  SizedBox(width: 10.w),
                  CustomText(
                    text: 'Add a service',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // Individual Service Card component
  Widget _buildServiceCard(Map<String, String> service) {
    return CustomContainer(
      radiusAll: 16.r,
      color: Colors.white,
      paddingAll: 16.r,
      marginBottom: 12.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: service['title']!,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              Icon(Icons.more_vert, size: 20.r, color: Colors.black), // Menu icon
            ],
          ),
          CustomText(
            text: service['subtitle']!,
            color: Colors.black45,
            fontSize: 13.sp,
            bottom: 12.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: service['type']!,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
              CustomText(
                text: service['phone']!,
                color: Colors.black45,
                fontSize: 13.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddServiceBottomSheet(BuildContext context) {
    final TextEditingController serviceNameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    Get.bottomSheet(
      isScrollControlled: true,
      CustomContainer(
        color: Colors.white,
        paddingAll: 20.r,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  const SizedBox(width: 32),
                  CustomText(
                    text: 'Add a service',
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

              CustomTextField(
                controller: serviceNameController,
                labelText: 'Service name',
                hintText: 'Service name',
                borderRadio: 12,
                contentPaddingHorizontal: 16.w,
              ),

              CustomTextField(
                controller: descriptionController,
                labelText: 'Description',
                hintText: 'Add a description',
                minLines: 5,
                maxLines: 8,
                borderRadio: 12,
                contentPaddingHorizontal: 16.w,
                contentPaddingVertical: 16.h,
              ),

              CustomContainer(
                radiusAll: 16.r,
                color: Colors.black.withOpacity(0.04), // Subtle gray background
                paddingAll: 16.r,
                marginBottom: 24.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Service charge range',
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                    Row(
                      children: [
                        _buildPriceBadge('\$60'),
                        SizedBox(width: 8.w),
                        _buildPriceBadge('\$120'),
                      ],
                    ),
                  ],
                ),
              ),

              CustomButton(
                label: 'Add service',
                backgroundColor: Colors.black.withOpacity(0.06),
                foregroundColor: Colors.grey.shade400,
                radius: 12.r,
                onPressed: () {
                  // Logic to save service details
                  Get.back();
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBadge(String price) {
    return CustomContainer(
      paddingHorizontal: 12.w,
      paddingVertical: 8.h,
      color: Colors.white,
      radiusAll: 8.r,
      child: CustomText(
        text: price,
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
      ),
    );
  }
}