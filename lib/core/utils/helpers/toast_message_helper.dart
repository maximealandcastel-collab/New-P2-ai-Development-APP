import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Helper class for showing toast messages using GetX Snackbar
class ToastMessageHelper {
  static void showSuccess(String message, {String? title, Duration? duration}) {
    Get.snackbar(
      title ?? 'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 2),
      borderRadius: 8.r,
      margin: EdgeInsets.all(16.r),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  static void showError(String message, {String? title, Duration? duration}) {
    Get.snackbar(
      title ?? 'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 3),
      borderRadius: 8.r,
      margin: EdgeInsets.all(16.r),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  static void showInfo(String message, {String? title, Duration? duration}) {
    Get.snackbar(
      title ?? 'Info',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 2),
      borderRadius: 8.r,
      margin: EdgeInsets.all(16.r),
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  static void showWarning(String message, {String? title, Duration? duration}) {
    Get.snackbar(
      title ?? 'Warning',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 2),
      borderRadius: 8.r,
      margin: EdgeInsets.all(16.r),
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }
}