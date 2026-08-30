import 'package:pler_to_pler_app/core/utils/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/utils/helpers/hive_cache_helper.dart';
import 'package:pler_to_pler_app/core/utils/helpers/prefs_helper.dart';

/// Local Data Source - Handles local storage (SharedPreferences, Hive, etc.)
abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
  Future<void> clearAuthData();
  Future<bool> isLoggedIn();
}

/// Implementation of Local Data Source
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> saveToken(String token) async {
    await PrefsHelper.setString(AppConstants.bearerToken, token);
  }

  @override
  Future<String?> getToken() async {
    final token = await PrefsHelper.getString(AppConstants.bearerToken);
    return token.isNotEmpty ? token : null;
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    // Save to Hive cache for quick access
    await HiveCacheHelper.save(
      key: AppConstants.cacheUserProfile,
      value: userData,
    );

    // Also save individual fields to SharedPreferences for persistence
    if (userData['email'] != null) {
      await PrefsHelper.setString(AppConstants.email, userData['email']);
    }
    if (userData['name'] != null) {
      await PrefsHelper.setString(AppConstants.name, userData['name']);
    }
    if (userData['role'] != null) {
      await PrefsHelper.setString(AppConstants.role, userData['role']);
    }
    if (userData['profilePicture'] != null) {
      await PrefsHelper.setString(AppConstants.profilePicture, userData['profilePicture']);
    }
    if (userData['userId'] != null) {
      await PrefsHelper.setString(AppConstants.userId, userData['userId']);
    }
    if (userData['isEmailVerified'] != null) {
      await PrefsHelper.setBool(
        AppConstants.isEmailVerified,
        userData['isEmailVerified'],
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    // Try to get from Hive cache first
    final cachedData = await HiveCacheHelper.get<Map<String, dynamic>>(
      key: AppConstants.cacheUserProfile,
    );

    if (cachedData != null) {
      return cachedData;
    }

    // Fallback to SharedPreferences
    final email = await PrefsHelper.getString(AppConstants.email);
    final name = await PrefsHelper.getString(AppConstants.name);
    final role = await PrefsHelper.getString(AppConstants.role);
    final profilePicture = await PrefsHelper.getString(AppConstants.profilePicture);
    final userId = await PrefsHelper.getString(AppConstants.userId);
    final isEmailVerified = await PrefsHelper.getBool(AppConstants.isEmailVerified);

    if (email.isEmpty && name.isEmpty) {
      return null;
    }

    return {
      'email': email,
      'name': name,
      'role': role,
      'profilePicture': profilePicture,
      'userId': userId,
      'isEmailVerified': isEmailVerified,
    };
  }

  @override
  Future<void> clearAuthData() async {
    await PrefsHelper.remove(AppConstants.bearerToken);
    await PrefsHelper.remove(AppConstants.email);
    await PrefsHelper.remove(AppConstants.name);
    await PrefsHelper.remove(AppConstants.role);
    await PrefsHelper.remove(AppConstants.profilePicture);
    await PrefsHelper.remove(AppConstants.userId);
    await PrefsHelper.remove(AppConstants.isEmailVerified);
    await PrefsHelper.remove(AppConstants.isLogged);
    
    // Clear Hive cache
    await HiveCacheHelper.delete(key: AppConstants.cacheUserProfile);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
