import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';

// Global variables to track last toast
String? _lastMessage;
DateTime? _lastShownTime;

void showToast(String message, {int? seconds}) {
  final now = DateTime.now();

  // Check if the same message was shown in last 3 seconds
  if (_lastMessage == message &&
      _lastShownTime != null &&
      now.difference(_lastShownTime!).inSeconds < (seconds ?? 3)) {
    return; // Don't show duplicate toast
  }

  _lastMessage = message;
  _lastShownTime = now;

  Get.snackbar(
    "System Notification",
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.transparent,
    colorText: Colors.white,
    duration: Duration(seconds: seconds ?? 3),
    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    borderRadius: 16.r,
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
    titleText: Padding(
      padding: EdgeInsets.only(left: 16.w, top: 8.h),
      child: Text(
        "System Notification",
        style: TextStyle(
          color: Colors.black,
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    ),
    messageText: ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.15),
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            message,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    ),
    padding: EdgeInsets.zero,
  );
}