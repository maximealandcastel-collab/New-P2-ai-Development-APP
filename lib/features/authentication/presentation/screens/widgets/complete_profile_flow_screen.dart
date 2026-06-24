import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/app_logo.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

typedef CompleteProfileNextHandler = Future<void> Function(
  int currentIndex,
  void Function(int index) navigateToPage,
  void Function() validateFormAfterNavigation,
);

class CompleteProfileFlowScreen extends StatefulWidget {
  const CompleteProfileFlowScreen({
    super.key,
    required this.pages,
    required this.formKey,
    required this.onNextPressed,
    required this.isLoading,
    this.logoBottomSpacing,
  });

  final List<Widget> pages;
  final GlobalKey<FormState> formKey;
  final CompleteProfileNextHandler onNextPressed;
  final bool isLoading;
  final double? logoBottomSpacing;

  @override
  State<CompleteProfileFlowScreen> createState() =>
      _CompleteProfileFlowScreenState();
}

class _CompleteProfileFlowScreenState extends State<CompleteProfileFlowScreen> {
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
    final showBackButton = _currentIndex > 0;

    return Scaffold(
      appBar: CustomAppBar(
        showLeading: showBackButton,
        leading: showBackButton
            ? IconButton(
                icon: Assets.icons.arrowBack.svg(height: 48.h, width: 48.w),
                onPressed: () {
                  if (_currentIndex > 0) {
                    _navigateToPage(_currentIndex - 1);
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    const AppLogoWidget(
                      subtitle: 'Let\'s start with building your profile',
                    ),
                    SizedBox(height: widget.logoBottomSpacing ?? 32.h),
                    widget.pages[index],
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
          child: CustomButton(
            onPressed: () => widget.onNextPressed(
              _currentIndex,
              _navigateToPage,
              _validateFormAfterNavigation,
            ),
            isLoading: widget.isLoading,
            label: _currentIndex == widget.pages.length - 1 ? 'Submit' : 'Next',
          ),
        ),
      ),
    );
  }
}
