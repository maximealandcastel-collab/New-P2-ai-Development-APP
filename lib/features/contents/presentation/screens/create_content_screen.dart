import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/create_content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/children/content_basic_info_page.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/children/content_equipment_tags_page.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/children/content_muscle_difficulty_page.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/children/content_video_details_page.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/create_content_flow_screen.dart';

class CreateContentScreen extends StatefulWidget {
  const CreateContentScreen({super.key});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<CreateContentController>();
    if (controller.isEditMode) {
      _showIntro = false;
    }
  }

  static const _pages = [
    ContentBasicInfoPage(),
    ContentVideoDetailsPage(),
    ContentMuscleDifficultyPage(),
    ContentEquipmentTagsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateContentController>();

    if (_showIntro) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Assets.icons.arrowBack.svg(height: 48.h, width: 48.w),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: '', 
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 32.sp),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              CustomText(
                text: 'Create a Post',
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: 'Share a workout, progress, or fitness moment.',
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 48.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: CustomButton(
                  label: '+ New Post',
                  width: double.infinity,
                  onPressed: () {
                    setState(() {
                      _showIntro = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Obx(
      () => CreateContentFlowScreen(
        pages: _pages,
        formKey: controller.formKey,
        isSubmitting: controller.isSubmitting.value,
        uploadProgress: controller.uploadProgress.value,
        submitLabel:
            controller.isEditMode ? 'Update content' : 'Post content',
        onBackToStart: !controller.isEditMode ? () {
          setState(() {
            _showIntro = true;
          });
        } : null,
        onNextPressed: (currentIndex, navigateToPage, validateAfterNav) async {
          final formValid =
              controller.formKey.currentState?.validate() ?? false;
          if (!formValid) return;

          if (!controller.validateStep(currentIndex)) {
            controller.showStepValidationMessage(currentIndex);
            validateAfterNav();
            return;
          }

          if (currentIndex < _pages.length - 1) {
            navigateToPage(currentIndex + 1);
            return;
          }

          for (var step = 0; step < _pages.length; step++) {
            if (!controller.validateStep(step)) {
              navigateToPage(step);
              validateAfterNav();
              return;
            }
          }

          await controller.submit();
        },
      ),
    );
  }
}
