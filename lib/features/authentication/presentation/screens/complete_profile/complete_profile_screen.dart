import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/children/bio_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/children/date_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/children/gender_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/children/names_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/children/profile_picture_page.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/screens/complete_profile/complete_payment_screen.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/widgets/app_logo.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  int currentIndex = 0;
  late PageController pageController;

  final List<Widget> pages = [
    NamesPage(),
    DatePage(),
    GenderPage(),
    ProfilePicturePage(),
    BioPage(),
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

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        backAction: () {
          if (currentIndex > 0) {
            _navigateToPage(currentIndex - 1);
          } else {
            Navigator.pop(context);
          }
        },
        titleWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pages.length,
                (index) => Expanded(
              child: CustomContainer(
                marginLeft: 4.w,
                height: 6.h,
                color: currentIndex == index
                    ? AppColors.textPrimary
                    : AppColors.textWhite,
                radiusAll: 99.r,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.to(() => const CompletePaymentScreen());
              // Handle skip action - navigate to next screen
            },
            child: CustomText(
              text: 'Skip',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 24.h),
          AppLogoWidget(
              subtitle: 'Let\'s start with building your profile',
          ),
          SizedBox(height: 40.h),
          Expanded(
            child: PageView.builder(
              controller: pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return pages[index];
              },
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: CustomButton(
            onPressed: () {
              if (currentIndex < pages.length - 1) {
                _navigateToPage(currentIndex + 1);
              } else {
                Get.to(() => const CompletePaymentScreen());
                // Handle completion - navigate to next screen
                // Navigator.pushReplacement(context, ...);
              }
            },
            label: 'Next',
          ),
        ),
      ),
    );
  }
}