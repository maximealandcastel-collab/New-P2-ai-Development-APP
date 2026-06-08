

import 'package:pler_to_pler_app/features/authentication/data/models/user_model.dart';
import 'package:pler_to_pler_app/features/authentication/data/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService({required AuthRepository repository}) : _repository = repository;

  /// ─── LOGIN ─────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _repository.login(email: email, password: password);

    return response;
  }

  /// ─── REGISTER ──────────────────────────
  Future<String> register({
    required String name,
    required String email,
    required String gender,
    required String confirmPassword,
  }) async {
    return await _repository.register(
      name: name,
      email: email,
      phone: gender,
      password: confirmPassword,
    );
  }

  /// ─── FORGOT PASSWORD ───────────────────
  Future<void> forgotPassword(String email) async {
    return await _repository.forgotPassword(email: email);
  }

  /// ─── OTP VERIFY ───────────────────
  Future<bool> otpVerify({required String otp}) async {
    return await _repository.otpVerify(otp: otp);
  }

  /// ─── RESEND OTP ───────────────────
  Future<void> resendOtp({required String email}) async {
    return await _repository.resendOtp(email: email);
  }

  /// ─── OTP VERIFY ───────────────────
  Future<void> resetPassword({
    required String newPassword,
  }) async {
    return await _repository.resetPassword(
      newPassword: newPassword,
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  /// ─── SESSION ───────────────────────────
  bool isLoggedIn() => _repository.isLoggedIn();

  String? getToken() => _repository.getAccessToken();

  Future<void> logout() => _repository.logout();

  UserModel? getCachedUser() => _repository.getCachedUser();
}
