import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class NavFabWidget {
  NavFabWidget._();

  static final NavFabWidget instance = NavFabWidget._();

  Future<dynamic> show(
    BuildContext context, {
    VoidCallback? onPostContent,
    VoidCallback? onAddSchedule,
    VoidCallback? onAddExercise,
  }) {
    final double bottomNavHeight = MediaQuery.of(context).padding.bottom + 44.h;

    return showCupertinoDialog(
      barrierColor: Colors.black.withOpacity(0.80),
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(child: GestureDetector(onTap: () => Get.back())),
            Positioned(
              bottom: bottomNavHeight + 44.h,
              right: 16.w,
              left: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 6.h,
                children: [
                  _buildMenuItem(
                    icon: Assets.icons.contents.svg(),
                    label: 'Post a content',
                    onTap: () {
                      Get.back();
                      onPostContent?.call();
                    },
                  ),
                  _buildMenuItem(
                    icon: Assets.icons.person.svg(),
                    label: 'Find Trainer',
                    onTap: () {
                      Get.back();
                      onAddSchedule?.call();
                    },
                  ),
                  _buildMenuItem(
                    icon: Assets.icons.exercise.svg(),
                    label: 'Add exercise plan',
                    onTap: () {
                      Get.back();
                      onAddExercise?.call();
                    },
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: bottomNavHeight - 24.h,
              right: 0,
              left: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: CustomContainer(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    paddingAll: 11.r,
                    child: const Icon(Icons.clear, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return CustomContainer(
      width: 182.w,
      color: Colors.white,
      radiusAll: 12.r,
      paddingAll: 12.r,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Flexible(
            child: FittedBox(
              child: CustomText(
                left: 4.w,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                text: label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
