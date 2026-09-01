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
  /// used to resolve the completed profile state.
  Future<String> resolveInitialRoute({
    bool? isProfileCompleted,
    bool? isSubscribed,
  }) async {
    try {
      await fetchUserProfile();
    } on AppException {
      // If the profile fetch fails and there is no cached data the user is
      // effectively unauthenticated — send them to login, NOT to the nav bar.
      // Sending to bottonNavBar with no token causes a chain of 401s.
      if (!hasCache()) {
        return AppRoute.loginScreen;
      }
    }

    final user = getCachedUserData();
    final profileDone =
        isProfileCompleted ?? (user?.onboardingCompleted == true);

    if (!profileDone) {
      if(user?.role == 'user') {
        return AppRoute.userCompleteProfileScreen;
      }else{
        return AppRoute.trainerCompleteProfileScreen;
      }
    }
    return AppRoute.bottonNavBar;
  }
}
