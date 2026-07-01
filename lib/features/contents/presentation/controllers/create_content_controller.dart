import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/helpers/photo_picker_helper.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/helpers/video_duration_helper.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';

class CreateContentController extends GetxController {
  CreateContentController({
    required ContentController contentController,
  }) : _contentController = contentController;

  final ContentController _contentController;

  static CreateContentController get to => Get.find();

  final formKey = GlobalKey<FormState>();
  final RxBool isSubmitting = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  final categoryController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final exerciseNameController = TextEditingController();
  final muscleGroupsController = TextEditingController();
  final difficultyController = TextEditingController();

  final RxList<String> selectedMuscleGroups = <String>[].obs;
  final RxList<String> equipment = <String>[].obs;
  final RxList<String> tags = <String>[].obs;

  final RxnString selectedCategoryId = RxnString();
  final RxnString selectedDifficulty = RxnString();
  final RxnString videoFileName = RxnString();
  final RxnString thumbnailPreviewPath = RxnString();
  final RxnString existingVideoUrl = RxnString();
  final RxnString existingThumbnailUrl = RxnString();
  final RxnInt durationSeconds = RxnInt();
  final RxnInt videoWidth = RxnInt();
  final RxnInt videoHeight = RxnInt();
  final RxBool isReadingVideoDuration = false.obs;

  File? videoFile;
  File? thumbnailFile;
  ContentModel? editingContent;

  bool get isEditMode => editingContent != null;

  static const int pageCount = 4;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ContentModel) {
      _populateEditData(args);
    }
  }

  void _populateEditData(ContentModel content) {
    editingContent = content;
    selectedCategoryId.value = content.categoryId?.id;
    categoryController.text = content.categoryId?.category ?? '';
    titleController.text = content.title ?? '';
    descriptionController.text = content.description ?? '';
    durationSeconds.value = content.durationSeconds;
    videoWidth.value = content.videoWidth;
    videoHeight.value = content.videoHeight;
    exerciseNameController.text = content.exerciseName ?? '';
    selectedDifficulty.value = content.difficulty;
    difficultyController.text = content.difficulty != null
        ? StringFormat.formatLabel(content.difficulty!)
        : '';
    selectedMuscleGroups.assignAll(content.muscleGroups ?? []);
    muscleGroupsController.text =
        StringFormat.formatSelectedList(selectedMuscleGroups);
    equipment.assignAll(content.equipment ?? []);
    tags.assignAll(content.tags ?? []);
    existingVideoUrl.value = content.videoUrl;
    existingThumbnailUrl.value = content.thumbnailUrl;
    videoFileName.value = content.videoUrl != null ? 'Existing video' : null;
    thumbnailPreviewPath.value = content.thumbnailUrl;
  }

  void onCategorySelected(String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  void onMuscleGroupsChanged(List<String> values) {
    selectedMuscleGroups.assignAll(values);
  }

  void onDifficultySelected(String value) {
    selectedDifficulty.value = value;
  }

  void onEquipmentChanged(List<String> values) {
    equipment.assignAll(values);
  }

  void onTagsChanged(List<String> values) {
    tags.assignAll(values);
  }

  Future<void> pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      final file = result?.files.first;
      if (file?.path == null) return;

      isReadingVideoDuration.value = true;

      final metadata = await VideoDurationHelper.metadataFromFilePath(file!.path!);
      if (metadata == null || metadata.durationSeconds <= 0) {
        ToastMessageHelper.show('Could not read video duration');
        return;
      }
      if (metadata.width <= 0 || metadata.height <= 0) {
        ToastMessageHelper.show('Could not read video dimensions');
        return;
      }

      videoFile = File(file.path!);
      videoFileName.value = file.name;
      durationSeconds.value = metadata.durationSeconds;
      videoWidth.value = metadata.width;
      videoHeight.value = metadata.height;
      existingVideoUrl.value = null;
    } catch (e) {
      ToastMessageHelper.show('Could not pick video file');
      if (kDebugMode) debugPrint('pickVideo error: $e');
    } finally {
      isReadingVideoDuration.value = false;
    }
  }

  Future<void> pickThumbnail(BuildContext context) async {
    PhotoPickerHelper.showPicker(
      context: context,
      onImagePicked: (file) {
        thumbnailFile = File(file.path);
        thumbnailPreviewPath.value = file.path;
        existingThumbnailUrl.value = null;
      },
    );
  }

  bool validateStep(int step) {
    switch (step) {
      case 0:
        return selectedCategoryId.value != null;
      case 1:
        final hasVideo = videoFile != null || existingVideoUrl.value != null;
        final hasThumbnail =
            thumbnailFile != null || existingThumbnailUrl.value != null;
        final hasDuration = (durationSeconds.value ?? 0) > 0;
        final hasDimensions = videoFile == null ||
            ((videoWidth.value ?? 0) > 0 && (videoHeight.value ?? 0) > 0);
        return hasVideo && hasThumbnail && hasDuration && hasDimensions;
      case 2:
        return selectedMuscleGroups.isNotEmpty &&
            _resolveDifficultyValue() != null;
      default:
        return true;
    }
  }

  String? _resolveDifficultyValue() {
    if (selectedDifficulty.value != null) return selectedDifficulty.value;

    final display = difficultyController.text.trim();
    if (display.isEmpty) return null;

    return StringFormat.contentDifficultyBackendValue(display);
  }

  void showStepValidationMessage(int step) {
    if (step != 1) return;

    if (videoFile == null && existingVideoUrl.value == null) {
      ToastMessageHelper.show('Please upload a video file');
    } else if (thumbnailFile == null && existingThumbnailUrl.value == null) {
      ToastMessageHelper.show('Please upload a thumbnail image');
    } else if ((durationSeconds.value ?? 0) <= 0) {
      ToastMessageHelper.show('Could not read video duration');
    } else if (videoFile != null &&
        ((videoWidth.value ?? 0) <= 0 || (videoHeight.value ?? 0) <= 0)) {
      ToastMessageHelper.show('Could not read video dimensions');
    }
  }

  String get formattedVideoDuration {
    final seconds = durationSeconds.value;
    if (seconds == null || seconds <= 0) return '';

    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$secs' : '$minutes:$secs';
  }

  Map<String, dynamic> _buildFields() {
    return {
      'categoryId': selectedCategoryId.value,
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'contentType': HelperData.contentType,
      'videoWidth': videoWidth.value,
      'videoHeight': videoHeight.value,
      'durationSeconds': durationSeconds.value ?? 0,
      'exerciseName': exerciseNameController.text.trim(),
      'muscleGroups': List<String>.from(selectedMuscleGroups),
      'difficulty': _resolveDifficultyValue(),
      'equipment': List<String>.from(equipment),
      'tags': List<String>.from(tags),
    };
  }

  Future<void> submit() async {
    if (isSubmitting.value) return;

    isSubmitting.value = true;
    uploadProgress.value = 0;

    try {
      await _contentController.createOrUpdateContent(
        fields: _buildFields(),
        video: videoFile,
        thumbnail: thumbnailFile,
        contentId: editingContent?.id,
        isEditMode: isEditMode,
      );
    } finally {
      if (!isClosed) {
        isSubmitting.value = false;
        uploadProgress.value = 0;
      }
    }
  }

  @override
  void onClose() {
    categoryController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    exerciseNameController.dispose();
    muscleGroupsController.dispose();
    difficultyController.dispose();
    super.onClose();
  }
}
