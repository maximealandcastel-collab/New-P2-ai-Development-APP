import 'package:pler_to_pler_app/features/authentication/data/models/login_result_model.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/trainer_profile_model.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/user_profile_model.dart';
import 'package:pler_to_pler_app/features/authentication/data/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService({required AuthRepository repository}) : _repository = repository;

  /// ─── LOGIN ─────────────────────────────
  Future<LoginResultModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _repository.login(email: email, password: password);

    return response;
  }

  /// ─── REGISTER ──────────────────────────
  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String role,
    required String password,
    String? referredByCode,
  }) async {
    return await _repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      gender: gender,
      role: role,
      password: password,
      referredByCode: referredByCode,
    );
  }

  /// ─── FORGOT PASSWORD ───────────────────
  Future<String> forgotPassword(String email) async {
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
  Future<void> resetPassword({required String newPassword,required String email}) async {
    return await _repository.resetPassword(newPassword: newPassword,email: email);
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

  Future<void> deleteAccount() async {
    await _repository.deleteAccount();
    await logout();
  }



  // ─── Trainer Profile  ────────────────────────────
  Future<void> registerTrainer(TrainerProfileModel data) async {
    return await _repository.registerTrainer(data);
  }

  // ─── User Profile  ────────────────────────────
  Future<void> registerUser(UserProfileModel data) async {
    return await _repository.registerUser(data);
  }

  /// ─── SESSION ───────────────────────────
  bool isLoggedIn() => _repository.isLoggedIn();

  String? getToken() => _repository.getAccessToken();

  Future<void> logout() => _repository.logout();

  String? getRole() => _repository.getRole();

  String? getGender() => _repository.getGender();

  /// Email cached at login — used to restore admin mode on app restart.
  String? getEmail() => _repository.getEmail();
}
