import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/profile/data/models/user_model.dart';


class ProfileRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  ProfileRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;


  // fetch user profile
  Future<UserModel> fetchUserProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.userProfile);
      final data = response.data['data'];
      final user = UserModel.fromJson(data);

      await _cacheService.put(AppConstants.cacheUserProfile, user.toJson());

      return user;
    } on AppException {
      final cached = getCachedUserData();
      if (cached != null) return cached;
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  UserModel? getCachedUserData() {
    try {
      final json = _cacheService.get<Map<String, dynamic>>(
        AppConstants.cacheUserProfile,
        defaultValue: null,
      );

      if (json == null) return null;
      return UserModel.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error getting cached user data: $e');
      return null;
    }
  }

  Future<UserModel> updateUserProfile(
      UserModel user, {
        File? image,
        File? cv,
        File? certificate,
      }) async {
    try {
      final formData = FormData.fromMap({
      });

      final response = await _apiService.dio.patch(
        ApiConstants.userProfileUpdate,
        data: formData,
      );

      final data = response.data['data'];
      final updatedUser = UserModel.fromJson(data);
      await _cacheService.put(
        AppConstants.cacheUserProfile,
        updatedUser.toJson(),
      );
      return updatedUser;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<UserModel> uploadProfilePicture(File file) async {
    try {
      final multipart = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );

      await _apiService.uploadFile(
        ApiConstants.uploadProfilePicture,
        file: multipart,
        fieldName: 'profilePicture',
      );

      return fetchUserProfile();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<UserModel> uploadCoverPhoto(File file) async {
    try {
      final multipart = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );

      await _apiService.uploadFile(
        ApiConstants.uploadCoverPhoto,
        file: multipart,
        fieldName: 'coverPhoto',
      );

      return fetchUserProfile();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }


  bool hasCache() {
    return _cacheService.containsKey(AppConstants.cacheUserProfile);
  }
}
