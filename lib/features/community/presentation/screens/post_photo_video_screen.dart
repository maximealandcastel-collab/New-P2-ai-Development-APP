import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/themes/p2p_design_tokens.dart';
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
  File? _extraPhoto;
  bool _posting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source, {bool extra = false}) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1800,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (extra) {
        _extraPhoto = File(picked.path);
      } else {
        _photo = File(picked.path);
      }
    });
  }

  void _showPhotoSource({bool extra = false}) {
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
                        _pickPhoto(ImageSource.camera, extra: extra);
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
                        _pickPhoto(ImageSource.gallery, extra: extra);
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

  /// The content upload contract stores one thumbnail. Keep both selections
  /// together in that file when a second photo is supplied.
  Future<File> _photoForUpload() async {
    if (_extraPhoto == null) return _photo!;
    final first = await _decodePhoto(_photo!);
    late final ui.Image second;
    try {
      second = await _decodePhoto(_extraPhoto!);
    } catch (_) {
      first.dispose();
      rethrow;
    }
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const side = 600.0;
    _drawCover(canvas, first, const ui.Rect.fromLTWH(0, 0, side, side));
    _drawCover(canvas, second, const ui.Rect.fromLTWH(side, 0, side, side));
    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(1200, 600);
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        if (bytes == null) throw StateError('Could not prepare photos.');
        final output = File('${Directory.systemTemp.path}/p2p-journey-${DateTime.now().microsecondsSinceEpoch}.png');
        await output.writeAsBytes(bytes.buffer.asUint8List());
        return output;
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
      first.dispose();
      second.dispose();
    }
  }

  Future<ui.Image> _decodePhoto(File file) async {
    final codec = await ui.instantiateImageCodec(await file.readAsBytes());
    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
    }
  }

  void _drawCover(ui.Canvas canvas, ui.Image image, ui.Rect destination) {
    final dimension = image.width < image.height ? image.width : image.height;
    final source = ui.Rect.fromLTWH(
      (image.width - dimension) / 2,
      (image.height - dimension) / 2,
      dimension.toDouble(), dimension.toDouble(),
    );
    canvas.drawImageRect(image, source, destination, ui.Paint()..filterQuality = ui.FilterQuality.high);
  }

  Future<void> _postPhoto() async {
    if (_photo == null || _posting) return;

    setState(() => _posting = true);
    File? combinedPhoto;
    try {
      final caption = _captionController.text.trim();
      final upload = await _photoForUpload();
      if (_extraPhoto != null) combinedPhoto = upload;
      final form = FormData.fromMap({
        'title': caption.isEmpty ? 'Community photo' : caption,
        'description': caption,
        'contentType': 'image',
        'thumbnail': await MultipartFile.fromFile(
          upload.path,
          filename: upload.path.split('/').last,
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
      try {
        if (combinedPhoto != null && await combinedPhoto.exists()) {
          await combinedPhoto.delete();
        }
      } catch (_) {
        // A failed temporary-file cleanup must not mask the upload result.
      }
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = BrandColors.of(context).primary;
    return Scaffold(
      backgroundColor: P2PColors.surface,
      appBar: AppBar(
        backgroundColor: P2PColors.surface,
        surfaceTintColor: P2PColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 19, color: P2PColors.charcoal),
        ),
        title: const Text('New Post',
            style: TextStyle(fontSize: 16, fontWeight: AppFontWeight.section)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Share your journey',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600,
                          color: P2PColors.charcoal)),
                  const SizedBox(height: 5),
                  const Text('Inspire the community with your progress, moments, and milestones.',
                      style: TextStyle(fontSize: 13, height: 1.4,
                          color: P2PColors.secondaryText)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _PhotoTile(
                          label: 'Upload photo',
                          hint: 'Tap to select',
                          file: _photo,
                          accent: orange,
                          onTap: _posting ? null : () => _showPhotoSource(),
                          onRemove: _posting ? null : () => setState(() => _photo = null),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PhotoTile(
                          label: 'Add more',
                          hint: 'Optional',
                          file: _extraPhoto,
                          accent: orange,
                          onTap: _posting ? null : () => _showPhotoSource(extra: true),
                          onRemove: _posting ? null : () => setState(() => _extraPhoto = null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Text('Caption (optional)',
                      style: TextStyle(fontSize: 13,
                          fontWeight: AppFontWeight.label,
                          color: P2PColors.charcoal)),
                  const SizedBox(height: 9),
                  TextField(
                    controller: _captionController,
                    maxLines: 3,
                    maxLength: 280,
                    style: const TextStyle(fontSize: 14, height: 1.4,
                        color: P2PColors.charcoal),
                    decoration: InputDecoration(
                      hintText: 'Describe your journey...',
                      hintStyle: const TextStyle(color: P2PColors.tertiaryText,
                          fontSize: 14),
                      filled: true,
                      fillColor: P2PColors.surface,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(P2PRadius.card),
                        borderSide: const BorderSide(color: P2PColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(P2PRadius.card),
                        borderSide: const BorderSide(color: P2PColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(P2PRadius.card),
                        borderSide: BorderSide(color: orange, width: 1.1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 23),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _photo == null || _posting ? null : _postPhoto,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: P2PColors.charcoal,
                        backgroundColor: P2PColors.surface,
                        side: BorderSide(color: orange, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(P2PRadius.pill),
                        ),
                      ),
                      child: _posting
                          ? SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: orange, strokeWidth: 2))
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Post to Community',
                                    style: TextStyle(fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                const SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded,
                                    color: orange, size: 19),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _posting ? null : () => Get.off(
                      () => const CreateContentScreen(),
                    ),
                    icon: Icon(Icons.videocam_outlined, color: orange, size: 19),
                    label: const Text('Post a video instead',
                        style: TextStyle(fontSize: 13,
                            fontWeight: AppFontWeight.label)),
                    style: TextButton.styleFrom(foregroundColor: P2PColors.charcoal),
                  ),
                ],
              ),
            ),
          ),
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
    required this.onRemove,
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

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.label,
    required this.hint,
    required this.file,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final String hint;
  final File? file;
  final Color accent;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: file == null ? '$label, $hint' : 'Change $label',
        child: Material(
          color: P2PColors.surface,
          borderRadius: BorderRadius.circular(P2PRadius.card),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(P2PRadius.card),
            child: Container(
              height: 166,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(P2PRadius.card),
                border: Border.all(
                  color: file == null ? P2PColors.border : accent,
                  width: file == null ? 1 : 1.2,
                ),
                boxShadow: P2PShadows.card,
              ),
              clipBehavior: Clip.antiAlias,
              child: file == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: .09),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_photo_alternate_outlined,
                              color: accent, size: 23),
                        ),
                        const SizedBox(height: 10),
                        Text(label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: P2PColors.charcoal)),
                        const SizedBox(height: 4),
                        Text(hint,
                            style: const TextStyle(
                                fontSize: 11,
                                color: P2PColors.secondaryText)),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(file!, fit: BoxFit.cover),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Semantics(
                            button: true,
                            label: 'Remove $label',
                            child: Material(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: onRemove,
                                borderRadius: BorderRadius.circular(20),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.close_rounded,
                                      color: Colors.white, size: 17),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit_outlined,
                                color: Colors.white, size: 17),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
}
