import 'package:get/get.dart';

class ToastMessageHelper {
  ToastMessageHelper._();

  static const Duration _cooldown = Duration(seconds: 3);
  static DateTime? _lastShownAt;

  static void show(String message) {
    final now = DateTime.now();
    if (_lastShownAt != null && now.difference(_lastShownAt!) < _cooldown) {
      return;
    }

    _lastShownAt = now;
    Get.snackbar(
      'Notification',
      message,
      snackPosition: SnackPosition.TOP,
    );
  }
}
