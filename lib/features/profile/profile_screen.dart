import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/features/profile/children/certificate_screen.dart';
import 'package:pler_to_pler_app/features/profile/children/edit_profile_screen.dart';
import 'package:pler_to_pler_app/features/profile/controller/profile_controller.dart';
import 'package:pler_to_pler_app/features/profile/widgets/services_card_widget.dart';
import 'package:pler_to_pler_app/features/profile/widgets/exercise_card_widget.dart';
import 'package:pler_to_pler_app/features/settings/settings_screen.dart';
import 'package:pler_to_pler_app/widgets/two_button_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already bound
    final ProfileController controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 232.h,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: Colors.black,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Assets.icons.arrowBack.svg(),
              onPressed: () => Navigator.pop(context),
            ),
            title: Obx(() => CustomText(
                  text: controller.isLoading ? 'Loading...' : 'Profile',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).scaffoldBackgroundColor,
                )),
            actions: [
              IconButton(
                onPressed: () {
                  Get.to(() => SettingsScreen());
                },
                icon: Assets.icons.setting.svg(
                  height: 48.r,
                  width: 48.r,
                ),
              ),
              // Refresh button
              Obx(() => controller.isLoading
                  ? Padding(
                      padding: EdgeInsets.all(8.r),
                      child: SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () => controller.refreshProfile(),
                      icon: Icon(Icons.refresh, color: Colors.white, size: 24.r),
                    )),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CustomContainer(
                child: Stack(
                  children: [
                    Assets.images.img2.image(
                      height: 221.h,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    Obx(() => Positioned(
                          top: 154.h,
                          left: 16.w,
                          child: CustomImageAvatar(
                            image: controller.currentUser?.profilePicture ??
                                "https://picsum.photos/300",
                            showBorder: true,
                            radius: 54.r,
                          ),
                        )),
                    Positioned(
                      bottom: 0.h,
                      right: 16.w,
                      child: CustomButton(
                        prefixIcon: Assets.icons.edit.svg(
                          height: 16.r,
                          width: 16.r,
                        ),
                        fontSize: 14.sp,
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        radius: 12.r,
                        height: 32.h,
                        width: 119.w,
                        onPressed: () {
                          Get.to(() => EditProfileScreen());
                        },
                        label: 'Edit Profile',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ======================>>>  Profile content =========================>>>
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show user name from API/cache or fallback
                      CustomText(
                        text: controller.userName,
                        fontSize: 24.sp,
                        fontWeight: AppFontWeight.section,
                      ),

                      SizedBox(height: 16.h),

                      TwoButtonWidget(
                        buttons: [
                          {'label': 'About me', 'value': 'about'},
                          {'label': 'Exercise plans', 'value': 'exercise'},
                        ],
                        selectedValue: controller.selectedButtonValue.value,
                        onTap: (String value) {
                          controller.selectedButtonValue.value = value;
                        },
                      ),

                      SizedBox(height: 16.h),

                      if (controller.selectedButtonValue.value == 'about') ...[
                        _buildBioCardWidget(
                          label: 'Bio',
                          value: controller.userEmail.isNotEmpty
                              ? controller.userEmail
                              : 'Welcome to the CEO\'s Channel ....',
                        ),
                        _buildBioCardWidget(
                          label: 'Specialties',
                          value: 'Strength, Rehab, Post-Op Recovery',
                        ),
                        _buildBioCardWidget(
                          label: 'Certifications',
                          value: 'ACE, NASM, PT Licences',
                        ),

                        CustomButton(
                          prefixIcon: Assets.icons.edit.svg(
                            height: 16.r,
                            width: 16.r,
                          ),
                          fontSize: 14.sp,
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          radius: 12.r,
                          height: 32.h,
                          width: 175.w,
                          onPressed: () {
                            Get.to(() => const CertificatesScreen());
                          },
                          label: 'Upload certification',
                        ),

                        SizedBox(height: 16.h),

                        _buildBioCardWidget(
                          label: 'Trainer Experience',
                          value: '8 years',
                        ),

                        SizedBox(height: 16.h),
                        CustomContainer(
                          radiusAll: 16.r,
                          width: double.infinity,
                          color: Colors.white,
                          paddingAll: 16.r,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: 'Availability',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                bottom: 16.h,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: controller.availabilityDays.map((day) {
                                  return _buildAvailabilityDay(
                                    day['day'],
                                    day['isAvailable'],
                                  );
                                }).toList(),
                              ),

                              SizedBox(height: 16.h),
                              CustomButton(
                                bordersColor: Colors.black.withValues(alpha: 0.08),
                                prefixIcon: Assets.icons.edit.svg(
                                  height: 20.r,
                                  width: 20.r,
                                ),
                                fontSize: 14.sp,
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                radius: 16.r,
                                onPressed: () {
                                  controller.showEditAvailabilitySheet(context);
                                },
                                label: 'Edit Availability',
                              ),
                            ],
                          ),
                        ),

                        // Services section
                        CustomText(
                          text: 'Services',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          top: 16.h,
                        ),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            return ServicesCardWidget();
                          },
                        ),
                      ],

                      if (controller.selectedButtonValue.value == 'exercise')
                        ListView.builder(
                          itemCount: 4,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ExerciseCardWidget();
                          },
                        ),

                      SizedBox(height: 32.h),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioCardWidget({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          color: AppColors.textSecondary,
          bottom: 6.h,
        ),
        CustomText(
          text: value,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          maxline: 1,
          textOverflow: TextOverflow.ellipsis,
          bottom: 10.h,
        ),
      ],
    );
  }

  Widget _buildAvailabilityDay(String day, bool isAvailable) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomContainer(
          width: 40.r,
          height: 40.r,
          shape: BoxShape.circle,
          color: isAvailable ? Colors.black : Colors.transparent,
          bordersColor: isAvailable ? Colors.black : Colors.grey.shade300,
          child: Center(
            child: CustomText(
              text: day,
              color: isAvailable ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CustomContainer(
          marginTop: 4.h,
          height: 4.h,
          width: 43.w,
          color: isAvailable ? Colors.green : Colors.black.withValues(alpha: 0.12),
        ),
      ],
    );
  }
}
