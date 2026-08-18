import 'package:pler_to_pler_app/features/authentication/data/data_sources/auth_local_data_source.dart';
import 'package:pler_to_pler_app/features/authentication/data/data_sources/auth_remote_data_source.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/user_model.dart';
import 'package:pler_to_pler_app/features/authentication/domain/entities/auth_entity.dart';
import 'package:pler_to_pler_app/features/authentication/domain/entities/user_entity.dart';
import 'package:pler_to_pler_app/features/authentication/domain/repositories/auth_repository.dart';

/// Repository Implementation
/// Bridges Domain Layer with Data Layer
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthEntity> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Call remote data source
      final authModel = await remoteDataSource.login(
        email: email,
        password: password,
        role: role,
      );

      // Save token and user data locally
      if (authModel.token != null) {
        await localDataSource.saveToken(authModel.token!);
      }
      if (authModel.user != null) {
        await localDataSource.saveUserData(authModel.user!.toJson());
      }

      // Return domain entity
      return authModel.toEntity();
    } catch (e) {
      // Handle error - you can add custom error mapping here
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthEntity> register({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final authModel = await remoteDataSource.register(
        email: email,
        password: password,
        role: role,
      );

      // Save token and user data locally if provided
      if (authModel.token != null) {
        await localDataSource.saveToken(authModel.token!);
      }
      if (authModel.user != null) {
        await localDataSource.saveUserData(authModel.user!.toJson());
      }

      return authModel.toEntity();
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthEntity> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final authModel = await remoteDataSource.verifyOtp(
        email: email,
        otp: otp,
      );

      if (authModel.token != null) {
        await localDataSource.saveToken(authModel.token!);
      }

      return authModel.toEntity();
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
    } catch (e) {
      throw Exception('Forgot password failed: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // TODO: Implement change password API call when endpoint is available
      throw UnimplementedError('Change password not implemented yet');
    } catch (e) {
      throw Exception('Change password failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    try {
      // First try to get from local cache
      final localUserData = await localDataSource.getUserData();
      if (localUserData != null) {
        return UserModel(
          email: localUserData['email'] ?? '',
          name: localUserData['name'],
          role: localUserData['role'],
          profilePicture: localUserData['profilePicture'],
          isEmailVerified: localUserData['isEmailVerified'],
          id: localUserData['userId'],
        ).toEntity();
      }

      // If not in cache, fetch from API
      final userModel = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUserData(userModel.toJson());
      return userModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? profilePicture,
  }) async {
    try {
      final userModel = await remoteDataSource.updateProfile(
        name: name,
        phone: phone,
        bio: bio,
        profilePicture: profilePicture,
      );

      // Update local cache
      await localDataSource.saveUserData(userModel.toJson());
      return userModel.toEntity();
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localDataSource.clearAuthData();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
