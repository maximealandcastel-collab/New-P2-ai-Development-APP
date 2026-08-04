import 'package:get/get.dart';

/// Tracks whether the admin PIN has been activated this session.
/// Registered on first PIN success; persists until app restart.
class AdminModeService extends GetxController {
  static AdminModeService get to => Get.find();

  final _isAdmin = false.obs;
  bool get isAdmin => _isAdmin.value;

  void activate() => _isAdmin.value = true;
}
