import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/children/additional_info_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/children/gym_info_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/children/physical_info_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/user/children/goal_setup_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/app_logo.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class UserCompleteProfileScreen extends StatefulWidget {
  const UserCompleteProfileScreen({super.key});

  @override
  State<UserCompleteProfileScreen> createState() =>
      _UserCompleteProfileScreenState();
}

class _UserCompleteProfileScreenState extends State<UserCompleteProfileScreen> {
  int currentIndex = 0;
  late PageController pageController;

  final List<Widget> pages = [
    GoalSetupPage(),
    PhysicalInfoPage(),
    GymInfoPage(),
    AdditionalInfoPage(),
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _validateFormAfterNavigation(ProfileCompleteController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.userFormKey.currentState?.validate();
    });
  }

  void _onNextPressed(ProfileCompleteController controller) {
    final formValid =
        controller.userFormKey.currentState?.validate() ?? false;
    if (!formValid) return;

    if (currentIndex < pages.length - 1) {
      _navigateToPage(currentIndex + 1);
      return;
    }

    for (var step = 0; step < pages.length; step++) {
      if (!controller.isUserTextStepValid(step)) {
        _navigateToPage(step);
        _validateFormAfterNavigation(controller);
        return;
      }
    }

    controller.registerUser();
  }

  @override
  Widget build(BuildContext context) {
    final showBackButton = currentIndex > 0;

    return Scaffold(
      appBar: CustomAppBar(
        showLeading: showBackButton,
        leading: showBackButton
            ? IconButton(
                icon: Assets.icons.arrowBack.svg(height: 48.h, width: 48.w),
                onPressed: () {
                  if (currentIndex > 0) {
                    _navigateToPage(currentIndex - 1);
                  }
                },
              )
            : null,
        titleWidget: StepProgressBar(
          stepCount: pages.length,
          currentIndex: currentIndex,
          showLeading: showBackButton,
        ),
        actions: [SizedBox(width: 24.w)],
      ),
      body: Form(
        key: ProfileCompleteController.to.userFormKey,
        child: PageView.builder(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          itemCount: pages.length,
          itemBuilder: (context, index) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    AppLogoWidget(
                      subtitle: 'Let\'s start with building your profile',
                    ),
                    SizedBox(height: 32.h),
                    pages[index],
                  ],
                ),
              ),
            );
          },
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Obx(() {
            final controller = ProfileCompleteController.to;
            return CustomButton(
              onPressed: () => _onNextPressed(controller),
              isLoading: controller.userState.isLoading,
              label: currentIndex == pages.length - 1 ? 'Submit' : 'Next',
            );
          }),
        ),
      ),
    );
  }
}
