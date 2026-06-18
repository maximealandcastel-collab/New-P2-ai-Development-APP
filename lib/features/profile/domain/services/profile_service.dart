import 'dart:io';

import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/profile/data/models/user_model.dart';
import 'package:pler_to_pler_app/features/profile/data/repositories/profile_repository.dart';

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

  Future<UserModel> updateUserProfile(
    UserModel user, {
    File? image,
    File? cv,
    File? certificate,
  }) async {
    return await _repository.updateUserProfile(
      user,
      image: image,
      cv: cv,
      certificate: certificate,
    );
  }

  bool hasCache() {
    return _repository.hasCache();
  }

  UserModel? getCachedUserData() {
    return _repository.getCachedUserData();
  }

  Future<String> resolveInitialRoute() async {
    try {
      await fetchUserProfile();
    } on AppException {
      if (!hasCache()) {
        return AppRoute.bottonNavBar;
      }
    }

    final user = getCachedUserData();
    if (user?.onboardingCompleted == true) {
      return AppRoute.findTrainerScreen;
    }

    if (user?.role == 'trainer') {
      return AppRoute.trainerCompleteProfileScreen;
    }

    return AppRoute.userCompleteProfileScreen;
  }
}
