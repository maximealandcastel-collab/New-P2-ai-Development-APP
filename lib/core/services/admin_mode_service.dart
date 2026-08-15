import 'package:get/get.dart';

/// Tracks whether admin mode is active and which view (admin / user) to show.
class AdminModeService extends GetxController {
  static AdminModeService get to => Get.find();

  final _isAdmin = false.obs;
  final _viewAsUser = false.obs;

  bool get isAdmin => _isAdmin.value;

  /// When true the admin is browsing the app as a regular user.
  bool get viewAsUser => _viewAsUser.value;

  void activate() => _isAdmin.value = true;

  /// Flip between admin view and user view.
  void toggleView() => _viewAsUser.value = !_viewAsUser.value;

  void setViewAsUser(bool val) => _viewAsUser.value = val;
}
