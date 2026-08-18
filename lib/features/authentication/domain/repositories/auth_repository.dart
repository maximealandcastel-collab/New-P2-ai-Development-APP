import 'package:pler_to_pler_app/features/authentication/domain/entities/auth_entity.dart';
import 'package:pler_to_pler_app/features/authentication/domain/entities/user_entity.dart';

/// Repository Interface - Defines contracts for data operations
/// This is part of Domain layer and should NOT depend on any external data sources
abstract class AuthRepository {
  /// Login with email and password
  Future<AuthEntity> login({
    required String email,
    required String password,
    required String role,
  });

  /// Register a new user
  Future<AuthEntity> register({
    required String email,
    required String password,
    required String role,
  });

  /// Verify OTP
  Future<AuthEntity> verifyOtp({
    required String email,
    required String otp,
  });

  /// Forgot password
  Future<void> forgotPassword({required String email});

  /// Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Get current user profile
  Future<UserEntity> getCurrentUser();

  /// Update user profile
  Future<UserEntity> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? profilePicture,
  });

  /// Logout - clear local data
  Future<void> logout();
}
