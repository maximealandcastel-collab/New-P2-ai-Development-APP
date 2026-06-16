import 'package:dio/dio.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';

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
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String role,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'gender': gender,
          'role': role,
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

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final responseData = response.data?['data'];
      final accessToken = responseData?['token']?.toString();
      final userRole = responseData?['user']?['role']?.toString();

      if (accessToken == null) {
        throw UnknownException('Access token not found');
      }

      await Future.wait([
        _cacheService.put(AppConstants.accessToken, accessToken),
        if (userRole != null)
          _cacheService.put(AppConstants.cacheUserRole, userRole),
      ]);

      return accessToken;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── Forgot Password ─────────────────────

  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post(ApiConstants.forgot, data: {'email': email});

      final token = response.data?['data']['token'];

      await _cacheService.put(AppConstants.otpToken, token);

      return token;
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
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'otp': otp},
      );

      final responseData = response.data?['data'];
      final accessToken = responseData?['token']?.toString();
      final userRole = responseData?['role']?.toString();

      if (accessToken == null) {
        throw UnknownException('Access token not found');
      }

      await Future.wait([
        _cacheService.put(AppConstants.accessToken, accessToken),
        if (userRole != null)
          _cacheService.put(AppConstants.cacheUserRole, userRole),
      ]);

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
        queryParameters: {'email': email},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── Reset Password ──────────────────────

  Future<void> resetPassword({required String newPassword,required String email}) async {
    try {
      await _apiService.post(
        ApiConstants.resetPassword,
        data: {
          "email": email,
          "password": newPassword
        },
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

  String? getRole() {
    return _cacheService.get<String>(AppConstants.cacheUserRole);
  }

  bool isLoggedIn() {
    return _cacheService.containsKey(AppConstants.accessToken);
  }

  // ─── Logout ──────────────────────────────

  Future<void> logout() {
    return _cacheService.clear();
  }
}
