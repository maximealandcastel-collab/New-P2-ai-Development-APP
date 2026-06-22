import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/app_logo.dart';
import 'package:pler_to_pler_app/features/trainer/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/content_form_constants.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/category_controller.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/children/content_basic_info_page.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/children/content_equipment_tags_page.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/children/content_muscle_difficulty_page.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/children/content_video_details_page.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CreateContentScreen extends StatefulWidget {
  const CreateContentScreen({super.key});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _contentController = ContentController.to;
  int _currentIndex = 0;

  final _categoryController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  final _durationController = TextEditingController();
  final _exerciseNameController = TextEditingController();
  final _muscleGroupsController = TextEditingController();
  final _difficultyController = TextEditingController();

  ContentModel? _editingContent;
  String? _selectedCategoryId;
  String? _selectedDifficulty;
  final List<String> _selectedMuscleGroups = [];
  final List<String> _equipment = [];
  final List<String> _tags = [];

  late final List<Widget> _pages;

  bool get _isEditMode => _editingContent != null;

  @override
  void initState() {
    super.initState();
    CategoryController.to.fetchCategories();
    _editingContent = Get.arguments as ContentModel?;
    _populateEditData();
    _pages = _buildPages();
  }

  void _populateEditData() {
    final content = _editingContent;
    if (content == null) return;

    _selectedCategoryId = content.categoryId?.id;
    _categoryController.text = content.categoryId?.category ?? '';
    _titleController.text = content.title ?? '';
    _descriptionController.text = content.description ?? '';
    _videoUrlController.text = content.videoUrl ?? '';
    _thumbnailUrlController.text = content.thumbnailUrl ?? '';
    _durationController.text = content.durationSeconds?.toString() ?? '';
    _exerciseNameController.text = content.exerciseName ?? '';
    _selectedDifficulty = content.difficulty;
    _difficultyController.text = content.difficulty != null
        ? ContentFormConstants.formatLabel(content.difficulty!)
        : '';
    _selectedMuscleGroups
      ..clear()
      ..addAll(content.muscleGroups ?? []);
    _muscleGroupsController.text =
        ContentFormConstants.formatSelectedList(_selectedMuscleGroups);
    _equipment
      ..clear()
      ..addAll(content.equipment ?? []);
    _tags
      ..clear()
      ..addAll(content.tags ?? []);
  }

  List<Widget> _buildPages() {
    return [
      ContentBasicInfoPage(
        categoryController: _categoryController,
        titleController: _titleController,
        descriptionController: _descriptionController,
        onCategorySelected: _onCategorySelected,
      ),
      ContentVideoDetailsPage(
        videoUrlController: _videoUrlController,
        thumbnailUrlController: _thumbnailUrlController,
        durationController: _durationController,
        exerciseNameController: _exerciseNameController,
      ),
      ContentMuscleDifficultyPage(
        muscleGroupsController: _muscleGroupsController,
        difficultyController: _difficultyController,
        selectedMuscleGroups: _selectedMuscleGroups,
        onMuscleGroupsChanged: (values) {
          setState(() {
            _selectedMuscleGroups
              ..clear()
              ..addAll(values);
          });
        },
        onDifficultySelected: (value) => _selectedDifficulty = value,
      ),
      ContentEquipmentTagsPage(
        initialEquipment: List<String>.from(_equipment),
        initialTags: List<String>.from(_tags),
        onEquipmentChanged: (values) => _equipment
          ..clear()
          ..addAll(values),
        onTagsChanged: (values) => _tags
          ..clear()
          ..addAll(values),
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _categoryController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _thumbnailUrlController.dispose();
    _durationController.dispose();
    _exerciseNameController.dispose();
    _muscleGroupsController.dispose();
    _difficultyController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String categoryId) {
    _selectedCategoryId = categoryId;
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return _selectedCategoryId != null;
      case 2:
        return _selectedMuscleGroups.isNotEmpty &&
            _resolveDifficultyValue() != null;
      default:
        return true;
    }
  }

  String? _resolveDifficultyValue() {
    if (_selectedDifficulty != null) return _selectedDifficulty;

    final display = _difficultyController.text.trim();
    if (display.isEmpty) return null;

    for (final value in ContentFormConstants.difficultyOptions) {
      if (ContentFormConstants.formatLabel(value) == display) {
        return value;
      }
    }
    return null;
  }

  void _validateFormAfterNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.validate();
    });
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'categoryId': _selectedCategoryId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'contentType': ContentFormConstants.contentType,
      'videoUrl': _videoUrlController.text.trim(),
      'thumbnailUrl': _thumbnailUrlController.text.trim(),
      'durationSeconds': int.tryParse(_durationController.text.trim()) ?? 0,
      'exerciseName': _exerciseNameController.text.trim(),
      'muscleGroups': List<String>.from(_selectedMuscleGroups),
      'difficulty': _resolveDifficultyValue(),
      'equipment': List<String>.from(_equipment),
      'tags': List<String>.from(_tags),
    };
  }

  Future<void> _onNextPressed() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    if (!_validateStep(_currentIndex)) {
      _validateFormAfterNavigation();
      return;
    }

    if (_currentIndex < _pages.length - 1) {
      _navigateToPage(_currentIndex + 1);
      return;
    }

    for (var step = 0; step < _pages.length; step++) {
      if (!_validateStep(step)) {
        _navigateToPage(step);
        _validateFormAfterNavigation();
        return;
      }
    }

    await _contentController.submitContent(
      data: _buildPayload(),
      editingContent: _editingContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: _currentIndex > 0
            ? IconButton(
                icon: Assets.icons.arrowBack.svg(height: 48.h, width: 48.w),
                onPressed: () {
                  if (_currentIndex > 0) {
                    _navigateToPage(_currentIndex - 1);
                  }
                },
              )
            : null,
        titleWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _pages.length,
            (index) => Expanded(
              child: CustomContainer(
                marginLeft: (index == 0 && _currentIndex == 0) ? 16.w : 4.w,
                height: 6.h,
                color: _currentIndex == index
                    ? AppColors.textPrimary
                    : AppColors.textWhite,
                radiusAll: 99.r,
              ),
            ),
          ),
        ),
        actions: [SizedBox(width: 24.w)],
      ),
      body: Form(
        key: _formKey,
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pages.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (context, index) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    AppLogoWidget(
                      subtitle: _isEditMode
                          ? 'Update your training content'
                          : 'Post your training content',
                    ),
                    SizedBox(height: 40.h),
                    _pages[index],
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Obx(
            () => CustomButton(
              onPressed: _contentController.submitLoadingState.isLoading
                  ? null
                  : _onNextPressed,
              isLoading: _contentController.submitLoadingState.isLoading,
              label: _currentIndex == _pages.length - 1
                  ? (_isEditMode ? 'Update content' : 'Post content')
                  : 'Next',
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
