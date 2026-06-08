import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/user_model.dart';
import '../../../core/helpers/hive_cache_helper.dart';

class ProfileController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();

  // Observable state
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isUploading = false.obs;
  final RxBool _hasLoadedInitialData = false.obs;
  final RxString _errorMessage = ''.obs;

  // Availability state
  final RxList<Map<String, dynamic>> availabilityDays = [
    {'day': 'M', 'isAvailable': false},
    {'day': 'T', 'isAvailable': true},
    {'day': 'W', 'isAvailable': false},
    {'day': 'T', 'isAvailable': true},
    {'day': 'F', 'isAvailable': true},
    {'day': 'S', 'isAvailable': false},
    {'day': 'S', 'isAvailable': false},
  ].obs;

  // Selected tab/button state
  final RxString selectedButtonValue = 'about'.obs;

  // Getters
  UserModel? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isUploading => _isUploading.value;
  bool get hasLoadedInitialData => _hasLoadedInitialData.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
  }









  /// Update availability day
  void updateAvailability(int index, bool isAvailable) {
    if (index >= 0 && index < availabilityDays.length) {
      availabilityDays[index]['isAvailable'] = isAvailable;
      availabilityDays.refresh();
    }
  }

  /// Get availability as comma-separated string
  String getAvailabilityString() {
    final availableDays = availabilityDays
        .where((day) => day['isAvailable'] == true)
        .map((day) => day['day'] as String)
        .toList();

    if (availableDays.isEmpty) {
      return 'Not available';
    }

    return availableDays.join(', ');
  }

  /// Check if user is available on specific day
  bool isAvailableOnDay(int dayIndex) {
    if (dayIndex >= 0 && dayIndex < availabilityDays.length) {
      return availabilityDays[dayIndex]['isAvailable'] == true;
    }
    return false;
  }

  /// Save availability to server
  Future<bool> saveAvailability() async {
    _isLoading.value = true;

    try {
      // TODO: Implement API call to save availability
      // Example: await _remoteDataSource.updateAvailability(availabilityDays);

      _isLoading.value = false;
      _showSuccessSnackbar('Availability updated successfully');
      return true;
    } catch (e) {
      _isLoading.value = false;
      _showErrorSnackbar('Failed to save availability: ${e.toString()}');
      return false;
    }
  }

  /// Clear cached data (call on logout)
  Future<void> clearCache() async {
    await HiveCacheHelper.delete(key: 'cache_user_profile');
    _currentUser.value = null;
    _hasLoadedInitialData.value = false;
    _errorMessage.value = '';
    update();
  }

  /// Get user initials for avatar fallback
  String getUserInitials() {
    final name = _currentUser.value?.name ?? '';
    if (name.isEmpty) {
      return 'U';
    }

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return name.substring(0, 1).toUpperCase();
  }

  /// Check if email is verified
  bool get isEmailVerified =>  false;

  /// Check if user is active
  bool get isActive =>  true;

  /// Get user role
  String get userRole => _currentUser.value?.role ?? 'Unknown';

  /// Get user email
  String get userEmail => _currentUser.value?.email ?? '';

  /// Get user name
  String get userName => _currentUser.value?.name ?? 'User';

  /// Get profile picture URL
  String get profilePictureUrl =>  '';

  /// Helper: Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  /// Helper: Show success snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }
}
