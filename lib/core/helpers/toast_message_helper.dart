import 'package:get/get.dart';

class ToastMessageHelper {
  ToastMessageHelper._();

  static void show(String message) {
    Get.snackbar(
      'Notification',
      message,
      snackPosition: SnackPosition.TOP,
    );
  }
}