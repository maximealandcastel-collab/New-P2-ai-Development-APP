import 'package:dio/dio.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  AuthRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  // ─── Register ────────────────────────────

  Future<String> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );

      final token = response.data?['data']['token'];

      await _cacheService.put(AppConstants.otpToken, token);

      return token;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── Login ───────────────────────────────

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final responseData = response.data?['data'];
      final userJson = responseData?['user'];
      final accessToken = responseData?['token'];

      final model = UserModel.fromJson(
        userJson is Map<String, dynamic> ? userJson : {},
      );

      if (accessToken != null) {
        await _cacheService.put(
          AppConstants.accessToken,
          accessToken.toString(),
        );
      }
      await _cacheService.put(AppConstants.cacheUser, model.toJson());

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── Forgot Password ─────────────────────

  Future<void> forgotPassword({required String email}) async {
    try {
      await _apiService.post(ApiConstants.forgot, data: {'email': email});
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── OTP Verify ──────────────────────────

  Future<bool> otpVerify({required String otp}) async {
    try {
      final token = await _cacheService.get(AppConstants.otpToken);
      final response = await _apiService.post(
        ApiConstants.otpVerify,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {'otp': otp},
      );

      final responseData = response.data?['data'];
      final accessToken = responseData?['token'];

      if (accessToken != null) {
        await _cacheService.put(
          AppConstants.accessToken,
          accessToken.toString(),
        );
      }
      return true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── Resend OTP ──────────────────────────
  Future<void> resendOtp({required String email}) async {
    try {
      final token = await _cacheService.get(AppConstants.otpToken);
      await _apiService.post(
        ApiConstants.resendOtp,
        queryParameters: {
          'email': email,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on AppException {
       rethrow;
     } catch (e) {
       throw UnknownException(e.toString());
     }
  }

  // ─── Reset Password ──────────────────────

  Future<void> resetPassword({required String newPassword}) async {
    try {
      await _apiService.post(
        ApiConstants.resetPassword,
        data: {'newPassword': newPassword},
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── Change Password ─────────────────────

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.changePassword,
        data: {'currentPassword': oldPassword, 'newPassword': newPassword},
      );

      final accessToken = response.data?['data']?['accessToken'];

      if (accessToken != null) {
        await _cacheService.put(
          AppConstants.accessToken,
          accessToken.toString(),
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── Cache Getters ───────────────────────

  String? getAccessToken() {
    return _cacheService.get<String>(AppConstants.accessToken);
  }

  UserModel? getCachedUser() {
    try {
      final json = _cacheService.get<Map<String, dynamic>>(
        AppConstants.cacheUser,
        defaultValue: null,
      );

      if (json == null) return null;

      return UserModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  bool isLoggedIn() {
    return _cacheService.containsKey(AppConstants.accessToken);
  }

  // ─── Logout ──────────────────────────────

  Future<void> logout() {
    return _cacheService.clear();
  }
}
