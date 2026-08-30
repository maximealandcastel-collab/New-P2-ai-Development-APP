import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';
import 'package:pler_to_pler_app/widgets/custom_app_bar.dart';
import 'package:pler_to_pler_app/widgets/custom_button.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';
import 'package:pler_to_pler_app/widgets/custom_scaffold.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';
import 'package:pler_to_pler_app/widgets/custom_text_field.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';

class ContentPostScreen extends StatefulWidget {
  const ContentPostScreen({super.key});

  @override
  State<ContentPostScreen> createState() => _ContentPostScreenState();
}

class _ContentPostScreenState extends State<ContentPostScreen> {
  // 0: Video, 1: Update
  int selectedTab = 0;

  // Video tab
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  File? selectedVideo;
  bool videoLoading = false;
  String videoError = '';

  // Update tab
  final updateTitleController = TextEditingController();
  final updateBodyController = TextEditingController();
  bool updateLoading = false;
  String updateError = '';

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    updateTitleController.dispose();
    updateBodyController.dispose();
    super.dispose();
  }

  // ── Pick video from gallery ───────────────────────────────────
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedVideo = File(picked.path);
        videoError = '';
      });
    }
  }

  // ── Upload video to backend ──────────────────────────────────
  Future<void> _postVideo() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      setState(() => videoError = 'Please enter a title');
      return;
    }
    if (selectedVideo == null) {
      setState(() => videoError = 'Please select a video first');
      return;
    }
    setState(() {
      videoLoading = true;
      videoError = '';
    });
    try {
      final response = await ApiClient.postMultipartData(
        ApiUrls.contentPost,
        {
          'title': title,
          'description': descriptionController.text.trim().isEmpty
              ? title
              : descriptionController.text.trim(),
          'audience': 'community',
        },
        multipartBody: [MultipartBody('video', selectedVideo!)],
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar(
          'Video Posted! 🎥',
          'Your video is now live in the feed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        setState(() => videoError =
            response.statusText ?? 'Upload failed. Please try again.');
      }
    } catch (_) {
      setState(() => videoError = 'Connection error. Please try again.');
    } finally {
      setState(() => videoLoading = false);
    }
  }

  // ── Broadcast text update to all clients ────────────────────
  Future<void> _postUpdate() async {
    final title = updateTitleController.text.trim();
    final body = updateBodyController.text.trim();
    if (title.isEmpty) {
      setState(() => updateError = 'Please enter a subject line');
      return;
    }
    if (body.isEmpty) {
      setState(() => updateError = 'Please enter your update message');
      return;
    }
    setState(() {
      updateLoading = true;
      updateError = '';
    });
    try {
      final response = await ApiClient.postData(
        ApiUrls.updateBroadcast,
        {'title': title, 'description': body},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final sent = (response.body is Map)
            ? (response.body['data']?['sent'] ?? 0)
            : 0;
        updateTitleController.clear();
        updateBodyController.clear();
        Get.back();
        Get.snackbar(
          'Update Sent! 📣',
          'Broadcast delivered to $sent client${sent == 1 ? '' : 's'}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        setState(() => updateError =
            response.statusText ?? 'Failed to send. Please try again.');
      }
    } catch (_) {
      setState(() => updateError = 'Connection error. Please try again.');
    } finally {
      setState(() => updateLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Post a Content'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Toggle
            CustomContainer(
              radiusAll: 14.r,
              color: Colors.white,
              paddingAll: 4.r,
              child: Row(
                children: [
                  _buildTabItem('Video', 0),
                  _buildTabItem('Update', 1),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            if (selectedTab == 0) _buildVideoLayout() else _buildUpdateLayout(),

            SizedBox(height: 32.h),

            // Error message
            if ((selectedTab == 0 ? videoError : updateError).isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: CustomText(
                  text: selectedTab == 0 ? videoError : updateError,
                  fontSize: 13.sp,
                  color: AppColors.error,
                  textAlign: TextAlign.center,
                ),
              ),

            // Post Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedTab == 0
                      ? (selectedVideo != null
                          ? AppColors.primary
                          : Colors.grey.shade300)
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                onPressed: (selectedTab == 0 ? videoLoading : updateLoading)
                    ? null
                    : (selectedTab == 0 ? _postVideo : _postUpdate),
                child: (selectedTab == 0 ? videoLoading : updateLoading)
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : CustomText(
                        text:
                            selectedTab == 0 ? 'Post Video' : 'Send to All Clients',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // ── Video layout ─────────────────────────────────────────────
  Widget _buildVideoLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUploadPlaceholder(),
        SizedBox(height: 24.h),
        _buildFieldLabel('Title'),
        CustomTextField(
          controller: titleController,
          hintText: 'Title of the video',
          borderRadio: 12.r,
        ),
        SizedBox(height: 16.h),
        _buildFieldLabel('Description'),
        CustomTextField(
          controller: descriptionController,
          hintText: 'Describe your video (optional)',
          maxLines: 5,
          minLines: 4,
          borderRadio: 12.r,
          prefixIcon: Icon(Icons.auto_awesome, size: 18.sp, color: Colors.grey),
        ),
      ],
    );
  }

  // ── Update layout ────────────────────────────────────────────
  Widget _buildUpdateLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Subject'),
        CustomTextField(
          controller: updateTitleController,
          hintText: 'e.g. "Week 3 check-in reminder"',
          borderRadio: 12.r,
        ),
        SizedBox(height: 16.h),
        _buildFieldLabel('Message'),
        CustomTextField(
          controller: updateBodyController,
          hintText: 'Write your update to all clients…',
          maxLines: 12,
          minLines: 8,
          borderRadio: 16.r,
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: 160.h),
            child: Icon(Icons.auto_awesome, size: 18.sp, color: Colors.grey),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFFFFD9AA)),
          ),
          child: Row(
            children: [
              Icon(Icons.people_outline,
                  size: 16.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomText(
                  text:
                      'This message will be sent to all your active clients.',
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  maxline: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          selectedTab = index;
          videoError = '';
          updateError = '';
        }),
        child: CustomContainer(
          radiusAll: 12.r,
          paddingVertical: 10.h,
          color: isSelected ? Colors.black : Colors.transparent,
          alignment: Alignment.center,
          child: CustomText(
            text: label,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        width: double.infinity,
        height: 200.h,
        decoration: BoxDecoration(
          color: selectedVideo != null
              ? const Color(0xFFFFF8F1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selectedVideo != null
                ? AppColors.primary
                : Colors.black12,
            width: selectedVideo != null ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35.r,
              backgroundColor: selectedVideo != null
                  ? const Color(0xFFFDEFE0)
                  : Colors.black.withOpacity(0.05),
              child: Icon(
                selectedVideo != null
                    ? Icons.check_circle_outline
                    : Icons.videocam_rounded,
                size: 32.sp,
                color: selectedVideo != null
                    ? AppColors.primary
                    : Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            CustomText(
              text: selectedVideo != null
                  ? selectedVideo!.path.split('/').last
                  : 'Tap to select a video',
              fontSize: 13.sp,
              fontWeight: selectedVideo != null
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: selectedVideo != null
                  ? AppColors.primary
                  : Colors.grey,
              textAlign: TextAlign.center,
              maxline: 2,
            ),
            SizedBox(height: 4.h),
            CustomText(
              text: selectedVideo != null
                  ? 'Tap to change'
                  : 'Max 30 minutes or 1 GB',
              fontSize: 11.sp,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: CustomText(
        text: label,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }
}
