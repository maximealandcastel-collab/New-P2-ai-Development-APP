import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/ai/presentation/controllers/train_ai_controller.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/avoid_accessory_page.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/cardio_must_use_page.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/communication_style_page.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/consistency_motivation_page.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/days_splits_page.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/intensity_page.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/natural_phrases_page.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/plateau_deload_page.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/plate_weekend_page.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/protein_hydration_page.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/rep_range_page.dart';
import 'package:pler_to_pler_app/features/ai/presentation/screens/children/rest_times_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/widgets/app_logo.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainAiScreen extends StatefulWidget {
  const TrainAiScreen({super.key});

  @override
  State<TrainAiScreen> createState() => _TrainAiScreenState();
}

class _TrainAiScreenState extends State<TrainAiScreen> {
  int currentIndex = 0;
  late PageController pageController;

  final List<Widget> pages = const [
    DaysSplitsPage(),
    RepRangePage(),
    RestTimesPage(),
    IntensityPage(),
    CardioMustUsePage(),
    AvoidAccessoryPage(),
    ProteinHydrationPage(),
    PlateWeekendPage(),
    ConsistencyMotivationPage(),
    PlateauDeloadPage(),
    NaturalPhrasesPage(),
    CommunicationStylePage(),
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

  void _validateFormAfterNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TrainAiController.to.formKey.currentState?.validate();
    });
  }

  void _onNextPressed(TrainAiController controller) {
    final formValid = controller.formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    if (!controller.validateStep(currentIndex)) return;

    if (currentIndex < pages.length - 1) {
      _navigateToPage(currentIndex + 1);
      return;
    }

    for (var step = 0; step < pages.length; step++) {
      if (!controller.validateStep(step)) {
        _navigateToPage(step);
        _validateFormAfterNavigation();
        return;
      }
    }

    controller.submitKnowledgePack();
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
        key: TrainAiController.to.formKey,
        child: PageView.builder(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pages.length,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    const AppLogoWidget(
                      subtitle: 'Train your personal AI',
                    ),
                    SizedBox(height: 24.h),
                    pages[index],
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
          child: Obx(() {
            final controller = TrainAiController.to;
            return CustomButton(
              onPressed: () => _onNextPressed(controller),
              isLoading: controller.submitState.isLoading,
              label: currentIndex == pages.length - 1 ? 'Submit' : 'Next',
            );
          }),
        ),
      ),
    );
  }
}
