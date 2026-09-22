import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/create_content_screen.dart';

class PostPhotoVideoScreen extends StatefulWidget {
  const PostPhotoVideoScreen({super.key});

  @override
  State<PostPhotoVideoScreen> createState() => _PostPhotoVideoScreenState();
}

class _PostPhotoVideoScreenState extends State<PostPhotoVideoScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  File? _photo;
  bool _posting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1800,
    );
    if (picked == null || !mounted) return;
    setState(() => _photo = File(picked.path));
  }

  void _showPhotoSource() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 22.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(99.r),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Add a photo',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: AppFontWeight.section,
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _pickPhoto(ImageSource.camera);
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Library',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _pickPhoto(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _postPhoto() async {
    if (_photo == null || _posting) return;

    setState(() => _posting = true);
    try {
      final caption = _captionController.text.trim();
      final form = FormData.fromMap({
        'title': caption.isEmpty ? 'Community photo' : caption,
        'description': caption,
        'contentType': 'image',
        'thumbnail': await MultipartFile.fromFile(
          _photo!.path,
          filename: _photo!.path.split('/').last,
        ),
      });

      await Get.find<ApiService>().postFormData(
        ApiConstants.content,
        formData: form,
      );

      if (Get.isRegistered<ContentController>()) {
        try {
          await ContentController.to.refresh();
        } catch (_) {}
      }

      BottomNavBarController.to.goToContentsTab();

      if (mounted) {
        Get.back();
        Get.snackbar(
          'Posted',
          'Your photo is now live.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (error) {
      if (mounted) {
        Get.snackbar(
          'Could not post photo',
          error.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = BrandColors.of(context).primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(fontWeight: AppFontWeight.section),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _photo == null || _posting ? null : _postPhoto,
            child: Text(
              _posting ? 'Posting...' : 'Post',
              style: TextStyle(
                color: _photo == null ? Colors.black26 : orange,
                fontWeight: AppFontWeight.section,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 30.h),
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19.r,
                    backgroundColor: orange.withOpacity(.12),
                    child: Icon(
                      Icons.person_rounded,
                      color: orange,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Share a fitness moment',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99.r),
                      border: Border.all(color: const Color(0xFFE7E7E7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.public_rounded, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'Community',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: _captionController,
              maxLines: 4,
              minLines: 3,
              maxLength: 280,
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                counterText: '',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 17.sp,
                ),
              ),
              style: TextStyle(fontSize: 17.sp),
            ),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: _showPhotoSource,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                height: 330.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: _photo == null
                        ? const Color(0xFFE7E7E7)
                        : orange.withOpacity(.45),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _photo != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_photo!, fit: BoxFit.cover),
                          Positioned(
                            top: 12.h,
                            right: 12.w,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () => setState(() => _photo = null),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12.w,
                            bottom: 12.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 11.w,
                                vertical: 7.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.65),
                                borderRadius: BorderRadius.circular(99.r),
                              ),
                              child: const Text(
                                'Tap to change',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70.w,
                            height: 70.w,
                            decoration: BoxDecoration(
                              color: orange.withOpacity(.11),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: orange,
                              size: 34.sp,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            'Add a photo',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: AppFontWeight.section,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            'Take a new photo or choose from your library',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showPhotoSource,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFE4E4E4)),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Photo'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.off(
                      () => const CreateContentScreen(),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFE4E4E4)),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text('Video'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            SizedBox(
              height: 54.h,
              child: FilledButton(
                onPressed: _photo == null || _posting ? null : _postPhoto,
                style: FilledButton.styleFrom(
                  backgroundColor: orange,
                  disabledBackgroundColor: const Color(0xFFE6E6E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  _posting ? 'Posting...' : 'Post Photo',
                  style: TextStyle(
                    color: _photo == null ? Colors.black38 : Colors.white,
                    fontWeight: AppFontWeight.section,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final orange = BrandColors.of(context).primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: Column(
          children: [
            Icon(icon, color: orange, size: 27.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: AppFontWeight.section,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
