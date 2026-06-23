import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/profile_complete_controller.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/children/certifications_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/children/speciality_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/children/trainer_tags_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/children/bio_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/trainer/children/subscription_price_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/app_logo.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerCompleteProfileScreen extends StatefulWidget {
  const TrainerCompleteProfileScreen({super.key});

  @override
  State<TrainerCompleteProfileScreen> createState() =>
      _TrainerCompleteProfileScreenState();
}

class _TrainerCompleteProfileScreenState
    extends State<TrainerCompleteProfileScreen> {
  int currentIndex = 0;
  late PageController pageController;

  final List<Widget> pages = [
    BioPage(),
    CertificationsPage(),
    SpecialityPage(),
    TrainerTagsPage(),
    SubscriptionPricePage(),
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
      controller.trainerFormKey.currentState?.validate();
    });
  }

  void _onNextPressed(ProfileCompleteController controller) {
    final formValid =
        controller.trainerFormKey.currentState?.validate() ?? false;
    if (!formValid) return;

    if (!controller.validateTrainerStep(currentIndex)) return;

    if (currentIndex < pages.length - 1) {
      _navigateToPage(currentIndex + 1);
      return;
    }

    for (var step = 0; step < pages.length; step++) {
      if (!controller.validateTrainerStep(step)) {
        _navigateToPage(step);
        return;
      }
      if (!controller.isTrainerTextStepValid(step)) {
        _navigateToPage(step);
        _validateFormAfterNavigation(controller);
        return;
      }
    }

    controller.registerTrainer();
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
        key: ProfileCompleteController.to.trainerFormKey,
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
                    SizedBox(height: 40.h),
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
              isLoading: controller.trainerState.isLoading,
              label: currentIndex == pages.length - 1 ? 'Submit' : 'Next',
            );
          }),
        ),
      ),

    );
  }
}
