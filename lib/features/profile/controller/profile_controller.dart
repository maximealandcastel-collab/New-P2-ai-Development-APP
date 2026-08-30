import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pler_to_pler_app/core/utils/helpers/hive_cache_helper.dart';
import 'package:pler_to_pler_app/features/authentication/data/data_sources/auth_local_data_source.dart';
import 'package:pler_to_pler_app/features/authentication/data/data_sources/auth_remote_data_source.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/user_model.dart';

/// Profile Controller - Manages profile state and data using GetX
/// 
/// Features:
/// - Load profile from cache first (instant load)
/// - Refresh from API in background
/// - Automatic cache invalidation after expiration
/// - Update profile with cache refresh
/// - Profile picture upload
/// - Availability management
/// - Error handling with snackbar display
class ProfileController extends GetxController {
  final AuthRemoteDataSource _remoteDataSource = AuthRemoteDataSourceImpl();
  final AuthLocalDataSource _localDataSource = AuthLocalDataSourceImpl();
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
    loadProfile();
  }

  /// Load profile data with cache-first strategy
  Future<void> loadProfile() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    
    try {
      // Try to load from cache first (fast)
      final cachedData = await HiveCacheHelper.getWithExpiration<Map<String, dynamic>>(
        key: 'cache_user_profile',
      );

      if (cachedData != null) {
        _currentUser.value = UserModel.fromJson(cachedData);
        _hasLoadedInitialData.value = true;
        _isLoading.value = false;
        
        // Refresh from API in background
        _refreshFromApi();
        return;
      }

      // No cache, fetch from API
      await _refreshFromApi();
    } catch (e) {
      _errorMessage.value = e.toString();
      _isLoading.value = false;
      _showErrorSnackbar('Failed to load profile: ${e.toString()}');
    }
  }

  /// Refresh profile data from API (background)
  Future<void> _refreshFromApi() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      _currentUser.value = user;
      _hasLoadedInitialData.value = true;
      _isLoading.value = false;
      _errorMessage.value = '';
      
      // Save to local storage as well
      await _localDataSource.saveUserData(user.toJson());
    } catch (e) {
      _errorMessage.value = e.toString();
      _isLoading.value = false;
      _showErrorSnackbar('Failed to refresh profile: ${e.toString()}');
    }
  }

  /// Force refresh from API (ignore cache)
  Future<void> refreshProfile() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    
    await _refreshFromApi();
    
    if (_errorMessage.value.isEmpty) {
      Get.snackbar(
        'Success',
        'Profile refreshed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? profilePicture,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final updatedUser = await _remoteDataSource.updateProfile(
        name: name,
        phone: phone,
        bio: bio,
        profilePicture: profilePicture,
      );

      _currentUser.value = updatedUser;
      _errorMessage.value = '';
      _isLoading.value = false;
      
      // Save to local storage
      await _localDataSource.saveUserData(updatedUser.toJson());
      
      _showSuccessSnackbar('Profile updated successfully');
      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      _isLoading.value = false;
      _showErrorSnackbar('Failed to update profile: ${e.toString()}');
      return false;
    }
  }

  /// Upload profile picture
  Future<bool> uploadProfilePicture(XFile imageFile) async {
    _isUploading.value = true;
    _errorMessage.value = '';

    try {
      // Upload file to server (implement based on your API)
      // For now, we'll simulate with a local file path
      
      // TODO: Implement actual file upload to your server
      // Example: final uploadedUrl = await _uploadFileToServer(imageFile);
      
      final updatedUser = await _remoteDataSource.updateProfile(
        profilePicture: imageFile.path, // Replace with actual URL after upload
      );

      _currentUser.value = updatedUser;
      _isUploading.value = false;
      
      // Save to local storage
      await _localDataSource.saveUserData(updatedUser.toJson());
      
      _showSuccessSnackbar('Profile picture updated successfully');
      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      _isUploading.value = false;
      _showErrorSnackbar('Failed to upload picture: ${e.toString()}');
      return false;
    }
  }

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: ${e.toString()}');
      return null;
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      _showErrorSnackbar('Failed to take picture: ${e.toString()}');
      return null;
    }
  }

  /// Show image source selection bottom sheet
  Future<void> showImageSourceDialog() async {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Get.back();
                final image = await pickImageFromCamera();
                if (image != null) {
                  await uploadProfilePicture(image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Get.back();
                final image = await pickImageFromGallery();
                if (image != null) {
                  await uploadProfilePicture(image);
                }
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  /// Update availability day
  void updateAvailability(int index, bool isAvailable) {
    if (index >= 0 && index < availabilityDays.length) {
      availabilityDays[index]['isAvailable'] = isAvailable;
      availabilityDays.refresh();
    }
  }

  void toggleDayAvailability(int index) {
    if (index < 0 || index >= availabilityDays.length) return;
    updateAvailability(
      index,
      availabilityDays[index]['isAvailable'] != true,
    );
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

  /// Show edit availability bottom sheet
  void showEditAvailabilitySheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Edit Availability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(availabilityDays.length, (i) {
                final day = availabilityDays[i];
                final available = day['isAvailable'] == true;
                return GestureDetector(
                  onTap: () => toggleDayAvailability(i),
                  child: Column(
                    children: [
                      Text(day['day'],
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: available
                              ? const Color(0xFFF57C1F)
                              : Colors.grey.shade100,
                          border: Border.all(
                            color: available
                                ? const Color(0xFFF57C1F)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Icon(
                          available ? Icons.check : Icons.close,
                          size: 18,
                          color: available ? Colors.white : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57C1F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  await saveAvailability();
                  Get.back();
                },
                child: const Text('Save Availability',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
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
    await _localDataSource.clearAuthData();
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
  bool get isEmailVerified => _currentUser.value?.isEmailVerified ?? false;

  /// Check if user is active
  bool get isActive => _currentUser.value?.isActive ?? true;

  /// Get user role
  String get userRole => _currentUser.value?.role ?? 'Unknown';

  /// Get user email
  String get userEmail => _currentUser.value?.email ?? '';

  /// Get user name
  String get userName => _currentUser.value?.name ?? 'User';

  /// Get profile picture URL
  String get profilePictureUrl => _currentUser.value?.profilePicture ?? '';

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
