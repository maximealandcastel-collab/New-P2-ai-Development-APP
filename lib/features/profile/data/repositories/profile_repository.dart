import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
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
      final user = _userFromResponseData(response.data?['data']);

      if (user == null) {
        throw UnknownException('Invalid profile response');
      }

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

  UserModel? _userFromResponseData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return UserModel.fromJson(data);
    }
    if (data is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  UserModel? getCachedUserData() {
    try {
      final json = _cacheService.get(AppConstants.cacheUserProfile);

      if (json is Map<String, dynamic>) {
        return UserModel.fromJson(json);
      }
      if (json is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting cached user data: $e');
      return null;
    }
  }

  Future<UserModel> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final current = getCachedUserData();
      final body = _buildProfileUpdateBody(current, updates);

      final response = await _apiService.put(
        ApiConstants.userProfile,
        data: body,
      );

      final updatedUser = _userFromResponseData(response.data?['data']);
      if (updatedUser != null) {
        await _cacheService.put(
          AppConstants.cacheUserProfile,
          updatedUser.toJson(),
        );
        return updatedUser;
      }

      return fetchUserProfile();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Map<String, dynamic> _buildProfileUpdateBody(
    UserModel? user,
    Map<String, dynamic> updates,
  ) {
    T? pick<T>(String key, T? fallback) {
      if (updates.containsKey(key)) return updates[key] as T?;
      return fallback;
    }

    String? resolveGender() {
      if (updates.containsKey('gender')) {
        return updates['gender'] as String?;
      }
      final gender = user?.gender;
      if (gender == null || gender.isEmpty) return null;
      return MenuShowHelper.genderBackendValue(
        MenuShowHelper.genderDisplayValue(gender),
      );
    }

    String? resolveFitnessLevel() {
      final value = pick<String>(
        'fitnessLevel',
        user?.fitnessLevel,
      );
      if (value == null || value.isEmpty) return null;
      return MenuShowHelper.fitnessLevelBackendValue(
        MenuShowHelper.fitnessLevelDisplayValue(value),
      );
    }

    String? resolveEquipment() {
      if (updates.containsKey('availableEquipment')) {
        return updates['availableEquipment'] as String?;
      }
      return MenuShowHelper.equipmentDisplayValue(user?.availableEquipment) ??
          user?.availableEquipment;
    }

    String? resolveMotivationStyle() {
      if (updates.containsKey('motivationStyle')) {
        return updates['motivationStyle'] as String?;
      }
      return MenuShowHelper.motivationStyleDisplayValue(user?.motivationStyle) ??
          user?.motivationStyle;
    }

    final body = <String, dynamic>{
      'firstName': pick('firstName', user?.firstName),
      'lastName': pick('lastName', user?.lastName),
      'dateOfBirth': pick('dateOfBirth', user?.dateOfBirth),
      'gender': resolveGender(),
      'height': pick('height', user?.height),
      'weight': pick('weight', user?.weight),
      'fitnessLevel': resolveFitnessLevel(),
      'primaryGoal': pick('primaryGoal', user?.primaryGoal),
      'availableEquipment': resolveEquipment(),
      'trainingDaysPerWeek': pick('trainingDaysPerWeek', user?.trainingDaysPerWeek),
      'injuries': updates.containsKey('injuries')
          ? updates['injuries']
          : user?.injuries ?? <String>[],
      'motivationStyle': resolveMotivationStyle(),
    };

    body.removeWhere((key, value) => value == null);
    return body;
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
