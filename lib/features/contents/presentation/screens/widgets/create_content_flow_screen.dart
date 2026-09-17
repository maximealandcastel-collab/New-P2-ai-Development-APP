import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

typedef CreateContentNextHandler = Future<void> Function(
  int currentIndex,
  void Function(int index) navigateToPage,
  void Function() validateFormAfterNavigation,
);

class CreateContentFlowScreen extends StatefulWidget {
  const CreateContentFlowScreen({
    super.key,
    required this.pages,
    required this.formKey,
    required this.onNextPressed,
    required this.isSubmitting,
    required this.uploadProgress,
    required this.submitLabel,
    this.onBackToStart,
    this.canSkipStep,
    this.onSkipPressed,
  });

  final List<Widget> pages;
  final GlobalKey<FormState> formKey;
  final CreateContentNextHandler onNextPressed;
  final bool isSubmitting;
  final double uploadProgress;
  final String submitLabel;
  final VoidCallback? onBackToStart;
  final bool Function(int index)? canSkipStep;
  final void Function(int index, void Function(int) navigateToPage)? onSkipPressed;

  @override
  State<CreateContentFlowScreen> createState() => _CreateContentFlowScreenState();
}

class _CreateContentFlowScreenState extends State<CreateContentFlowScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _validateFormAfterNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.formKey.currentState?.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final canPopRoute = Navigator.canPop(context);
    final showBackButton = _currentIndex > 0 || canPopRoute;

    return Scaffold(
      appBar: CustomAppBar(
        showLeading: showBackButton,
        leading: showBackButton
            ? IconButton(
                icon: Assets.icons.arrowBack.svg(height: 48.h, width: 48.w),
                onPressed: () {
                  if (_currentIndex > 0) {
                    _navigateToPage(_currentIndex - 1);
                  } else if (widget.onBackToStart != null) {
                    widget.onBackToStart!();
                  } else if (canPopRoute) {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
        titleWidget: StepProgressBar(
          stepCount: widget.pages.length,
          currentIndex: _currentIndex,
          showLeading: showBackButton,
        ),
        actions: [SizedBox(width: 24.w)],
      ),
      body: Form(
        key: widget.formKey,
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.pages.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
              child: widget.pages[index],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.uploadProgress > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(99.r),
                  child: LinearProgressIndicator(
                    value: widget.uploadProgress,
                    minHeight: 6.h,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text:
                      'Uploading ${(widget.uploadProgress * 100).round()}%',
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 12.h),
              ],
              CustomButton(
                onPressed: widget.isSubmitting
                    ? null
                    : () => widget.onNextPressed(
                          _currentIndex,
                          _navigateToPage,
                          _validateFormAfterNavigation,
                        ),
                isDisabled: widget.isSubmitting,
                label: _currentIndex == widget.pages.length - 1
                    ? widget.submitLabel
                    : 'Next',
                width: double.infinity,
              ),
              if (widget.canSkipStep?.call(_currentIndex) == true) ...[
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: widget.isSubmitting
                      ? null
                      : () => widget.onSkipPressed?.call(_currentIndex, _navigateToPage),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
