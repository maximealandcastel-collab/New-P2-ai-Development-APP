import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/photo_picker_helper.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/trainer/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/content_controller.dart';

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
  final durationController = TextEditingController();
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
    durationController.text = content.durationSeconds?.toString() ?? '';
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

      videoFile = File(file!.path!);
      videoFileName.value = file.name;
      existingVideoUrl.value = null;
    } catch (e) {
      ToastMessageHelper.show('Could not pick video file');
      if (kDebugMode) debugPrint('pickVideo error: $e');
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
        return hasVideo && hasThumbnail;
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
    }
  }

  Map<String, dynamic> _buildFields() {
    return {
      'categoryId': selectedCategoryId.value,
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'contentType': MenuShowHelper.contentType,
      'durationSeconds': int.tryParse(durationController.text.trim()) ?? 0,
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
    durationController.dispose();
    exerciseNameController.dispose();
    muscleGroupsController.dispose();
    difficultyController.dispose();
    super.onClose();
  }
}
