import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/helpers/image_crop_helper.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/themes/p2p_design_tokens.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/services/network/api_client.dart';
import 'package:video_player/video_player.dart';

enum P2PPostRole { user, trainer, gymAdmin }

/// The role and destination are data, while the composer layout is shared.
class P2PPostComposerConfig {
  const P2PPostComposerConfig({
    this.role = P2PPostRole.user,
    this.destination = ApiConstants.content,
    this.videoDestination = ApiUrls.contentPost,
  });

  final P2PPostRole role;
  final String destination;
  final String videoDestination;
}

/// Compatibility entry for existing navigation and the old before/after route.
class PostPhotoVideoScreen extends StatelessWidget {
  const PostPhotoVideoScreen({super.key, this.config = const P2PPostComposerConfig()});

  final P2PPostComposerConfig config;

  @override
  Widget build(BuildContext context) => P2PPostComposer(config: config);
}

class P2PPostComposer extends StatefulWidget {
  const P2PPostComposer({super.key, required this.config});

  final P2PPostComposerConfig config;

  @override
  State<P2PPostComposer> createState() => _P2PPostComposerState();
}

class _P2PPostComposerState extends State<P2PPostComposer> {
  final _picker = ImagePicker();
  final _caption = TextEditingController();
  File? _photo;
  File? _video;
  VideoPlayerController? _videoPreview;
  String? _tag;
  String? _location;
  String? _workout;
  bool _posting = false;

  @override
  void dispose() {
    _caption.dispose();
    _videoPreview?.dispose();
    super.dispose();
  }

  void _message(String title, String body) {
    Get.snackbar(title, body, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source, imageQuality: 88, maxWidth: 1800,
      );
      if (picked == null || !mounted) return;
      final file = File(picked.path);
      final sized = await _choosePhotoSize(file);
      if (!mounted || sized == null) return;
      final previous = _videoPreview;
      setState(() {
        _photo = sized;
        _video = null;
        _videoPreview = null;
      });
      await previous?.dispose();
    } catch (_) {
      if (mounted) _message('Photo unavailable', 'Please try choosing the photo again.');
    }
  }

  Future<File?> _choosePhotoSize(File file) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Size your photo',
                  style: TextStyle(fontSize: 17, fontWeight: AppFontWeight.section)),
              const SizedBox(height: 5),
              const Text('Choose how it appears in your post.',
                  style: TextStyle(fontSize: 12, color: P2PColors.secondaryText)),
              for (final option in const [
                ('Original', 'Keep the full photo'),
                ('Square', 'Crop to 1:1'),
                ('Portrait', 'Crop to 4:5'),
                ('Landscape', 'Crop to 16:9'),
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option.$1),
                  subtitle: Text(option.$2),
                  onTap: () => Navigator.pop(sheetContext, option.$1),
                ),
            ],
          ),
        ),
      ),
    );
    if (choice == null) return file;
    if (choice == 'Original') return file;
    if (!mounted) return null;
    final size = switch (choice) {
      'Square' => const ImageCropConfig(cropWidth: 1, cropHeight: 1),
      'Portrait' => const ImageCropConfig(cropWidth: 4, cropHeight: 5),
      _ => const ImageCropConfig(cropWidth: 16, cropHeight: 9),
    };
    return ImageCropHelper.cropImage(
      imagePath: file.path,
      config: size,
      accentColor: BrandColors.of(context).primary,
    );
  }

  Future<void> _pickVideo() async {
    try {
      // Gallery only: no video camera or live capture path.
      final picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked == null || !mounted) return;
      final file = File(picked.path);
      final preview = VideoPlayerController.file(file);
      try {
        await preview.initialize();
      } catch (_) {
        await preview.dispose();
        rethrow;
      }
      if (!mounted) {
        await preview.dispose();
        return;
      }
      final previous = _videoPreview;
      setState(() {
        _video = file;
        _photo = null;
        _videoPreview = preview;
      });
      await previous?.dispose();
    } catch (_) {
      if (mounted) _message('Video unavailable', 'Please choose an existing video from your library.');
    }
  }

  Future<void> _editText({required String title, required ValueChanged<String?> save,
      String? initial, String hint = ''}) async {
    final input = TextEditingController(text: initial ?? '');
    try {
      final value = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: input,
            autofocus: true,
            maxLength: 80,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(dialogContext, input.text.trim()),
                child: const Text('Save')),
          ],
        ),
      );
      if (value != null && mounted) setState(() => save(value.isEmpty ? null : value));
    } finally {
      input.dispose();
    }
  }

  void _chooseWorkout() {
    final history = Get.isRegistered<ProfileController>()
        ? ProfileController.to.userData?.workoutHistory ?? const []
        : const [];
    final names = <String>[];
    for (final item in history) {
      if (item is! Map) continue;
      final label = (item['name'] ?? item['title'] ?? item['goal'])?.toString().trim();
      if (label != null && label.isNotEmpty && !names.contains(label)) names.add(label);
    }
    if (names.isEmpty) {
      _message('No workouts yet', 'Your saved workouts will appear here when available.');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Add workout')),
            for (final name in names.take(20))
              ListTile(
                title: Text(name),
                onTap: () {
                  setState(() => _workout = name);
                  Navigator.pop(sheetContext);
                },
              ),
            if (_workout != null)
              ListTile(
                title: const Text('Remove workout'),
                onTap: () {
                  setState(() => _workout = null);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  String get _postText {
    final parts = <String>[
      if (_caption.text.trim().isNotEmpty) _caption.text.trim(),
      if (_tag != null) '@${_tag!.replaceFirst(RegExp(r'^@'), '')}',
      if (_location != null) 'Location: $_location',
      if (_workout != null) 'Workout: $_workout',
    ];
    return parts.join('\n');
  }

  Future<void> _publish() async {
    if (_posting || (_photo == null && _video == null)) return;
    setState(() => _posting = true);
    try {
      final description = _postText;
      final title = _caption.text.trim().isEmpty
          ? 'Community post'
          : _caption.text.trim().split('\n').first;
      if (_video != null) {
        // Existing community video upload contract accepts a library video.
        final response = await ApiClient.postMultipartData(
          widget.config.videoDestination,
          {
            'title': title,
            'description': description,
            'audience': 'community',
          },
          multipartBody: [MultipartBody('video', _video!)],
        );
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw StateError(response.statusText ?? 'Video upload failed');
        }
      } else {
        final form = FormData.fromMap({
          'title': title,
          'description': description,
          'contentType': 'image',
          'audience': 'community',
          'thumbnail': await MultipartFile.fromFile(
            _photo!.path, filename: _photo!.path.split('/').last,
          ),
        });
        await Get.find<ApiService>().postFormData(
          widget.config.destination, formData: form,
        );
      }
      if (Get.isRegistered<ContentController>()) {
        try { await ContentController.to.refresh(); } catch (_) {}
      }
      if (Get.isRegistered<BottomNavBarController>()) {
        BottomNavBarController.to.goToContentsTab();
      }
      if (mounted) {
        Get.back();
        _message('Posted', 'Your post is now live.');
      }
    } catch (error) {
      if (mounted) _message('Could not post', error.toString());
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = BrandColors.of(context).primary;
    final hasMedia = _photo != null || _video != null;
    return Scaffold(
      backgroundColor: P2PColors.surface,
      appBar: AppBar(
        backgroundColor: P2PColors.surface,
        surfaceTintColor: P2PColors.surface,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: Get.back),
        title: const Text('New Post',
            style: TextStyle(fontSize: 15, fontWeight: AppFontWeight.section)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(children: [
                    const TextSpan(text: 'Share ', style: TextStyle(color: P2PColors.charcoal)),
                    TextSpan(text: 'your journey', style: TextStyle(color: orange)),
                  ]), style: const TextStyle(fontSize: 21, fontWeight: AppFontWeight.section)),
                  const SizedBox(height: 5),
                  const Text('Inspire the community with your progress, moments, and milestones.',
                      style: TextStyle(fontSize: 12, height: 1.4,
                          color: P2PColors.secondaryText)),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: _MediaChoice(
                        label: 'Choose from\nCamera Roll', icon: Icons.photo_library_outlined,
                        accent: orange, onTap: _posting ? null : () => _pickPhoto(ImageSource.gallery),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _MediaChoice(
                        label: 'Take a Photo', icon: Icons.camera_alt_outlined,
                        accent: orange, onTap: _posting ? null : () => _pickPhoto(ImageSource.camera),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _MediaChoice(
                        label: 'Add Video', icon: Icons.videocam_outlined,
                        accent: orange, onTap: _posting ? null : _pickVideo,
                      )),
                    ],
                  ),
                  if (hasMedia) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 128,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _MediaPreview(
                            photo: _photo,
                            video: _videoPreview,
                            onRemove: _posting ? null : () {
                              final old = _videoPreview;
                              setState(() { _photo = null; _video = null; _videoPreview = null; });
                              old?.dispose();
                            },
                            onResize: _posting || _photo == null ? null : () async {
                              final sized = await _choosePhotoSize(_photo!);
                              if (sized != null && mounted) setState(() => _photo = sized);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  TextField(
                    controller: _caption,
                    maxLength: 280,
                    maxLines: 3,
                    minLines: 3,
                    style: const TextStyle(fontSize: 14, color: P2PColors.charcoal),
                    decoration: InputDecoration(
                      hintText: 'Share a moment, thought, or update...',
                      hintStyle: const TextStyle(color: P2PColors.tertiaryText, fontSize: 13),
                      filled: true,
                      fillColor: P2PColors.surface,
                      contentPadding: const EdgeInsets.all(15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(P2PRadius.card),
                        borderSide: const BorderSide(color: P2PColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(P2PRadius.card),
                        borderSide: BorderSide(color: orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(icon: Icons.person_outline_rounded,
                    title: 'Tag people', value: _tag == null ? null : '@$_tag',
                    onTap: () => _editText(title: 'Mention someone',
                      hint: 'Username', initial: _tag,
                      save: (v) => _tag = v?.replaceFirst(RegExp(r'^@'), ''))),
                  _DetailRow(icon: Icons.location_on_outlined,
                    title: 'Add location', value: _location,
                    onTap: () => _editText(title: 'Add location',
                      hint: 'City or gym', initial: _location, save: (v) => _location = v)),
                  _DetailRow(icon: Icons.fitness_center_outlined,
                    title: 'Add workout', value: _workout, onTap: _chooseWorkout),
                  _DetailRow(icon: Icons.people_outline_rounded,
                    title: 'Post to Community', value: 'Public',
                    onTap: () => _message('Public audience',
                      'Private audience controls are not available for community posts yet.')),
                  const SizedBox(height: 18),
                  Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(P2PRadius.pill),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF191A20), Color(0xFF633119), Color(0xFFD96921)],
                      ),
                      boxShadow: const [BoxShadow(color: Color(0x1BBA5A1B),
                          blurRadius: 9, offset: Offset(0, 3))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: hasMedia && !_posting ? _publish : null,
                        borderRadius: BorderRadius.circular(P2PRadius.pill),
                        child: Center(
                          child: _posting
                              ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Row(mainAxisSize: MainAxisSize.min, children: [
                                  Text('Post to Community', style: TextStyle(
                                    color: hasMedia ? Colors.white : Colors.white60,
                                    fontWeight: AppFontWeight.label, fontSize: 14)),
                                  const SizedBox(width: 10),
                                  Icon(Icons.arrow_forward_rounded,
                                      color: hasMedia ? Colors.white : Colors.white60, size: 18),
                                ]),
                        ),
                      ),
                    ),
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

class _MediaChoice extends StatelessWidget {
  const _MediaChoice({required this.label, required this.icon,
      required this.accent, required this.onTap});
  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: P2PColors.surface,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            height: 116,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: P2PColors.border),
              borderRadius: BorderRadius.circular(17),
              boxShadow: P2PShadows.card,
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(radius: 20, backgroundColor: accent.withValues(alpha: .08),
                  child: Icon(icon, color: accent, size: 21)),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, maxLines: 2,
                  style: const TextStyle(fontSize: 11, height: 1.15,
                      fontWeight: AppFontWeight.label, color: P2PColors.charcoal)),
            ]),
          ),
        ),
      );
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.photo, required this.video,
      required this.onRemove, required this.onResize});
  final File? photo;
  final VideoPlayerController? video;
  final VoidCallback? onRemove;
  final VoidCallback? onResize;

  @override
  Widget build(BuildContext context) => Stack(children: [
        Container(
          width: 126, height: 126,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
              border: Border.all(color: P2PColors.border)),
          child: photo != null
              ? Image.file(photo!, fit: BoxFit.contain)
              : video != null && video!.value.isInitialized
                  ? GestureDetector(
                      onTap: () => video!.value.isPlaying ? video!.pause() : video!.play(),
                      child: Stack(fit: StackFit.expand, children: [
                        FittedBox(fit: BoxFit.cover,
                          child: SizedBox(width: video!.value.size.width,
                            height: video!.value.size.height, child: VideoPlayer(video!))),
                        const Center(child: Icon(Icons.play_circle_outline_rounded,
                            color: Colors.white, size: 36)),
                      ]),
                    )
                  : const SizedBox.shrink(),
        ),
        if (onRemove != null)
          Positioned(right: 5, top: 5, child: _PreviewAction(
            icon: Icons.close_rounded, label: 'Remove media', onTap: onRemove!)),
        if (onResize != null)
          Positioned(right: 5, bottom: 5, child: _PreviewAction(
            icon: Icons.crop_rounded, label: 'Crop or resize photo', onTap: onResize!)),
      ]);
}

class _PreviewAction extends StatelessWidget {
  const _PreviewAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true, label: label,
        child: Material(color: Colors.black54, shape: const CircleBorder(),
          child: InkWell(onTap: onTap, customBorder: const CircleBorder(),
            child: Padding(padding: const EdgeInsets.all(5),
              child: Icon(icon, size: 18, color: Colors.white))),
        ),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.title, this.value, required this.onTap});
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: const BoxDecoration(border: Border(
              bottom: BorderSide(color: P2PColors.border))),
          child: Row(children: [
            CircleAvatar(radius: 16, backgroundColor: const Color(0xFFF5F5F6),
                child: Icon(icon, color: P2PColors.charcoal, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13,
                color: P2PColors.charcoal))),
            if (value != null) Flexible(child: Text(value!, maxLines: 1,
                overflow: TextOverflow.ellipsis, style: const TextStyle(
                  fontSize: 12, color: P2PColors.secondaryText))),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                size: 19, color: P2PColors.secondaryText),
          ]),
        ),
      );
}
