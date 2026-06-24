import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/features/profile/data/models/user_model.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _service;
  final ConnectivityService _connectivityService;

  static ProfileController get to => Get.find();

  ProfileController({
    required ProfileService service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;

  // ─── Loading States ────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;

  final Rx<LoadingState> _updateLoadingState = LoadingState.initial.obs;

  LoadingState get updateLoadingState => _updateLoadingState.value;

  // ─── User Data ─────────────────────────────────────────────────────────────

  final _userData = Rxn<UserModel>();

  UserModel? get userData => _userData.value;

  final _selectedProfilePicture = Rxn<File>();
  final _selectedCoverPhoto = Rxn<File>();

  File? get selectedProfilePicture => _selectedProfilePicture.value;
  File? get selectedCoverPhoto => _selectedCoverPhoto.value;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) loadData();
    });
    loadData();
  }

  // ─── Load Data ─────────────────────────────────────────────────────────────
  Future<void> loadData() async {
    try {
      final hasCache = _service.hasCache();
      final isOnline = _connectivityService.isConnected.value;

      if (hasCache) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }

      if (!isOnline) return;

      try {
        await _service.fetchUserProfile();
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch error: $e');
      }
    } catch (e) {
      if (_service.hasCache()) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected error: $e');
    }
  }

  // ─── Cache ─────────────────────────────────────────────────────────────────
  void _loadFromCache() {
    _userData.value = _service.getCachedUserData();
    assert(() {
      if (kDebugMode) {
        print('📦 Loaded from cache:');
      }
      return true;
    }());
  }

  @override
  Future<void> refresh() => loadData();

  Future<void> uploadProfilePicture(File file) async {
    _selectedProfilePicture.value = file;
    _updateLoadingState.value = LoadingState.loading;
    try {
      _userData.value = await _service.uploadProfilePicture(file);
      _selectedProfilePicture.value = null;
      _updateLoadingState.value = LoadingState.loaded;
    } on AppException catch (e) {
      _selectedProfilePicture.value = null;
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
    } catch (e) {
      _selectedProfilePicture.value = null;
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show('Failed to upload profile picture');
      if (kDebugMode) debugPrint('Upload profile picture error: $e');
    }
  }

  Future<void> uploadCoverPhoto(File file) async {
    _selectedCoverPhoto.value = file;
    _updateLoadingState.value = LoadingState.loading;
    try {
      _userData.value = await _service.uploadCoverPhoto(file);
      _selectedCoverPhoto.value = null;
      _updateLoadingState.value = LoadingState.loaded;
    } on AppException catch (e) {
      _selectedCoverPhoto.value = null;
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
    } catch (e) {
      _selectedCoverPhoto.value = null;
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show('Failed to upload cover photo');
      if (kDebugMode) debugPrint('Upload cover photo error: $e');
    }
  }

  Future<bool> updateProfileInformation(Map<String, dynamic> data) async {
    _updateLoadingState.value = LoadingState.loading;
    try {
      _userData.value = await _service.updateUserProfile(data);
      _updateLoadingState.value = LoadingState.loaded;
      return true;
    } on AppException catch (e) {
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      return false;
    } catch (e) {
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show('Failed to update profile');
      if (kDebugMode) debugPrint('Update profile error: $e');
      return false;
    }
  }
}
