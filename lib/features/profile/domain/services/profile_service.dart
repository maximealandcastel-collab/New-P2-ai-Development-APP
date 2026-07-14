import 'dart:io';

import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/profile/data/models/user_model.dart';
import 'package:pler_to_pler_app/features/profile/data/repositories/profile_repository.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';

class ProfileService {
  final ProfileRepository _repository;

  ProfileService({required ProfileRepository repository})
    : _repository = repository;

  Future<void> fetchUserProfile() async {
    try {
      await Future.wait([_repository.fetchUserProfile()]);
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> fetchTrainerProfile() async {
    try {
      await _repository.fetchTrainerProfile();
    } on AppException {
      if (!_repository.hasTrainerCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<UserModel> updateUserProfile(Map<String, dynamic> data) async {
    return await _repository.updateUserProfile(data);
  }

  Future<UserModel> uploadProfilePicture(File file) async {
    return _repository.uploadProfilePicture(file);
  }

  Future<UserModel> uploadCoverPhoto(File file) async {
    return _repository.uploadCoverPhoto(file);
  }

  bool hasCache() {
    return _repository.hasCache();
  }

  UserModel? getCachedUserData() {
    return _repository.getCachedUserData();
  }

  TrainerDetailsModel? getCachedTrainerProfile() {
    return _repository.getCachedTrainerProfile();
  }

  bool hasTrainerCache() {
    return _repository.hasTrainerCache();
  }

  /// Resolves where to land after login / app start.
  ///
  /// [isProfileCompleted] and [isSubscribed] come from the login response when
  /// available; when omitted (e.g. splash auto-login) the cached profile is
  /// used and subscription gating is skipped.
  Future<String> resolveInitialRoute({
    bool? isProfileCompleted,
    bool? isSubscribed,
  }) async {
    try {
      await fetchUserProfile();
    } on AppException {
      if (!hasCache()) {
        return AppRoute.bottonNavBar;
      }
    }

    final user = getCachedUserData();
    final profileDone =
        isProfileCompleted ?? (user?.onboardingCompleted == true);

    if (!profileDone) {
      return AppRoute.userCompleteProfileScreen;
    }
    if (isSubscribed == false) {
      return AppRoute.subscribeSelectScreen;
    }
    return AppRoute.bottonNavBar;
  }
}
