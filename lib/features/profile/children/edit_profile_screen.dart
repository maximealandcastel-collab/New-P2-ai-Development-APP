import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/profile/children/services_screen.dart';

import '../../../core/utils/constants/app_colors.dart';
import '../../../custom_assets/assets.gen.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_container.dart';
import '../../../widgets/custom_image_avatar.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/custom_text_field.dart';
import 'certificate_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers for the form fields
  final TextEditingController nameController = TextEditingController(text: "Maxime Castel");
  final TextEditingController usernameController = TextEditingController(text: "@maximectl");
  final TextEditingController bioController = TextEditingController(text: "Welcome to the CEO's Chanel ....");
  final TextEditingController specialtyController = TextEditingController();

  int selectedExperience = 8;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Reuse the same SliverAppBar logic from ProfileScreen
          SliverAppBar(
            expandedHeight: 232.h,
            pinned: true,
            backgroundColor: AppColors.backgroundLight,
            leading: IconButton(
              icon: Assets.icons.arrowBack.svg(),
              onPressed: () => Navigator.pop(context),
            ),
            title: CustomText(
              text: 'Edit profile',
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Assets.icons.setting.svg(height: 48.r, width: 48.r),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CustomContainer(
                child: Stack(
                  children: [
                    Assets.images.img2.image(height: 221.h, fit: BoxFit.cover, width: double.infinity),
                    // Profile Image with Update Icon
                    Positioned(
                      top: 154.h,
                      left: 16.w,
                      child: Stack(
                        children: [
                          CustomImageAvatar(image: 'https://picsum.photos/300', showBorder: true, radius: 54.r),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: _buildRefreshIcon(),
                          ),
                        ],
                      ),
                    ),
                    // Cover Update Icon
                    Positioned(
                      top: 154.h,
                      right: 16.w,
                      child: _buildRefreshIcon(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  CustomText(text: 'Professional details', fontSize: 18.sp, fontWeight: FontWeight.w700),

                  SizedBox(height: 16.h),
                  // Using your CustomTextField for all inputs
                  CustomTextField(
                    controller: nameController,
                    labelText: 'Full name',
                    hintText: 'Maxime Castel',
                    prefixIcon: Icon(Icons.person, color: Colors.grey, size: 20.r),
                    contentPaddingHorizontal: 16.w,
                    borderRadio: 12,
                  ),

                  CustomTextField(
                    controller: usernameController,
                    labelText: 'Username',
                    hintText: '@maximectl',
                    prefixIcon: Icon(Icons.person, color: Colors.grey, size: 20.r),
                    contentPaddingHorizontal: 16.w,
                    borderRadio: 12,
                  ),

                  _buildSelectorTile(
                    label: 'Years of experience',
                    value: '8 Years',
                    onTap: () => _showExperiencePicker(),
                  ),
                  SizedBox(height: 16.h),

                  CustomTextField(
                    controller: bioController,
                    labelText: 'Bio',
                    hintText: 'Enter your bio',
                    minLines: 5, // Force it to start big
                    maxLines: 8, // Allow it to expand further
                    contentPaddingHorizontal: 16.w,
                    contentPaddingVertical: 12.h,
                    borderRadio: 12,
                  ),

                  CustomTextField(
                    controller: specialtyController,
                    labelText: 'Specialties',
                    hintText: 'Add specialty',
                    contentPaddingHorizontal: 16.w,
                    borderRadio: 12,
                  ),

                  // Inside EditProfileScreen Column:
                  _buildRedirectTile(
                    'No certificates been added',
                    onTap: () => Get.to(() => const CertificatesScreen()),
                  ),

                  SizedBox(height: 24.h),
                  CustomText(text: 'Services', fontSize: 18.sp, fontWeight: FontWeight.w700),

                  SizedBox(height: 16.h),

                  // UPDATED: Availability Card to match UI
                  _buildAvailabilityCard(),

                  SizedBox(height: 16.h),

                  _buildRedirectTile(
                    'No Services available',
                    onTap: () => Get.to(() => const ServicesScreen()),
                  ),


                  SizedBox(height: 40.h),
                  CustomButton(
                    label: 'Save',
                    backgroundColor: Colors.black.withOpacity(0.06),
                    foregroundColor: Colors.grey.shade400,
                    onPressed: () {},
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper for the small white update icons on images
  Widget _buildRefreshIcon() {
    return CustomContainer(
      height: 32.r, width: 32.r,
      shape: BoxShape.circle,
      color: Colors.white,
      child: Center(child: Icon(Icons.refresh, size: 16.r)),
    );
  }

  Widget _buildLabel(String text) => CustomText(text: text, color: AppColors.textSecondary, bottom: 8.h, fontSize: 14.sp);

  Widget _buildTextField({TextEditingController? controller, required String hint, IconData? prefix, int maxLines = 1}) {
    return CustomContainer(
      radiusAll: 12.r,
      bordersColor: Colors.black.withOpacity(0.05),
      color: Colors.white,
      paddingAll: 12.r,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: prefix != null ? Icon(prefix, color: Colors.grey, size: 20.r) : null,
        ),
      ),
    );
  }

  Widget _buildSelectorTile({required String label, required String value, required VoidCallback onTap}) {
    return CustomContainer(
      radiusAll: 12.r,
      color: Colors.white,
      paddingAll: 12.r,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: label, fontWeight: FontWeight.w500),
          CustomContainer(
            paddingAll: 8.r,
            color: Colors.black.withOpacity(0.05),
            radiusAll: 8.r,
            child: CustomText(text: value, fontSize: 14.sp),
          )
        ],
      ),
    );
  }

  Widget _buildRedirectTile(String text, {VoidCallback? onTap}) {
    return CustomContainer(
      radiusAll: 12.r,
      color: Colors.white,
      paddingAll: 16.r,
      marginTop: 16.h,
      onTap: onTap, // Ensure the custom container has an onTap property
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: text, fontWeight: FontWeight.w500),
          Icon(Icons.arrow_forward_ios, size: 16.r, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return CustomContainer(
      radiusAll: 16.r,
      color: Colors.white,
      paddingAll: 16.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: 'Availability', fontSize: 16.sp, fontWeight: FontWeight.w600, bottom: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayCircle('M', false),
              _buildDayCircle('T', true),
              _buildDayCircle('W', false),
              _buildDayCircle('T', true),
              _buildDayCircle('F', true),
              _buildDayCircle('S', false),
              _buildDayCircle('S', true),
            ],
          ),
          SizedBox(height: 16.h),
          CustomButton(
            prefixIcon: Icon(Icons.edit_note, size: 20.r, color: Colors.black),
            label: 'Edit Availability',
            fontSize: 14.sp,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            bordersColor: Colors.black.withOpacity(0.08),
            radius: 12.r,
            onPressed: () => _showAvailabilityPicker(),
          )
        ],
      ),
    );
  }


  Widget _buildDayCircle(String day, bool isAvailable) {
    return Column(
      children: [
        CustomContainer(
          height: 36.r, width: 36.r,
          shape: BoxShape.circle,
          color: isAvailable ? Colors.black : Colors.grey.shade50,
          bordersColor: isAvailable ? Colors.black : Colors.grey.shade200,
          child: Center(
            child: CustomText(
              text: day,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isAvailable ? Colors.white : Colors.black54,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        // Green/Grey indicator line
        Container(
          height: 3.h,
          width: 32.w,
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green : Colors.black.withOpacity(0.08),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }


  // Bottom Sheet for Experience Picker (image_67df6a.png)
  void _showExperiencePicker() {
    Get.bottomSheet(
      isScrollControlled: true,
      CustomContainer(
        color: Colors.white,
        paddingAll: 20.r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)), ),

            CustomText(
              text: 'Years of experience',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              bottom: 20.h,
            ),

            // Circular Scrolling Area
            SizedBox(
              height: 200.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The selection highlight bars (top and bottom)
                  Positioned(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Divider(color: Colors.black.withOpacity(0.1), thickness: 1),
                        SizedBox(height: 45.h),
                        Divider(color: Colors.black.withOpacity(0.1), thickness: 1),
                      ],
                    ),
                  ),

                  // The Actual Scroll Wheel
                  ListWheelScrollView.useDelegate(
                    itemExtent: 50.h,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedExperience = index;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 50, // Years range 0-49
                      builder: (context, index) {
                        return Center(
                          child: CustomText(
                            text: index < 10 ? '0 $index' : '$index', // Matches "0 8" format
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            CustomButton(
              label: 'Choose time',
              backgroundColor: const Color(0xFFFF7A00), // Matching the orange in your UI
              foregroundColor: Colors.white,
              radius: 12.r,
              onPressed: () {
                // Update the state so the tile shows the new value
                Get.back();
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }


  // Bottom Sheet for Availability (image_67df42.png)
  void _showAvailabilityPicker() {
    Get.bottomSheet(
      isScrollControlled: true,
      CustomContainer(
        color: Colors.white,
        paddingAll: 20.r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, color: Colors.black,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Opacity(opacity: 0, child: Icon(Icons.close)),
                CustomText(text: 'Availability', fontSize: 18.sp, fontWeight: FontWeight.bold),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: CustomContainer(
                    paddingAll: 4.r,
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                    child: Icon(Icons.close, size: 20.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // Day selection row with checkmarks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCheckableDay('Mon', true),
                _buildCheckableDay('Tue', false),
                _buildCheckableDay('Wed', true),
                _buildCheckableDay('Thu', true),
                _buildCheckableDay('Fri', false),
                _buildCheckableDay('Sat', true),
                _buildCheckableDay('Sun', false),
              ],
            ),
            SizedBox(height: 32.h),
            CustomButton(
              label: 'Save',
              backgroundColor: Colors.orange, // Based on UI screenshot
              foregroundColor: Colors.white,
              onPressed: () => Get.back(),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckableDay(String day, bool isSelected) {
    return Column(
      children: [
        CustomText(text: day, fontSize: 12.sp, bottom: 8.h, color: Colors.black54),
        CustomContainer(
          height: 28.r, width: 28.r,
          shape: BoxShape.circle,
          color: isSelected ? Colors.green : Colors.grey.shade50,
          bordersColor: isSelected ? Colors.green : Colors.grey.shade300,
          child: isSelected ? Icon(Icons.check, color: Colors.white, size: 16.r) : null,
        ),
      ],
    );
  }

}