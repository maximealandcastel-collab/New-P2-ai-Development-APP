import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/contents_category_chips.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/contents_tab_selector.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsHeaderSection extends StatelessWidget {
  const ContentsHeaderSection({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  static double preferredHeight({required bool isTrainer}) {
    return isTrainer ? 110.h : 160.h;
  }

  @override
  Widget build(BuildContext context) {
    final contentController = ContentController.to;
    final isTrainer = ProfileController.to.userData?.role == 'trainer';

    return CustomContainer(
      topLeftRadius: 16.r,
      topRightRadius: 16.r,
      paddingTop: 16.h,
      paddingBottom: 8.h,
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            left: 16.w,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            text: 'All Contents',
          ),
          SizedBox(height: 8.h),
          if (!isTrainer) const ContentsTabSelector(),
          Obx(() {
            if (!isTrainer &&
                contentController.activeTab.value == ContentTab.defaultContent) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CustomSearchField(
                  readOnly: true,
                  onTap: onSearchTap,
                  searchController: contentController.searchController,
                  hintText: 'Search default exercises...',
                ),
              );
            }
            return const ContentsCategoryChips();
          }),
        ],
      ),
    );
  }
}
