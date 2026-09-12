import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_constants.dart'
    as legacy_constants;
import 'package:pler_to_pler_app/core/utils/helpers/prefs_helper.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/login_result_model.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/trainer_profile_model.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/user_profile_model.dart';

class AuthRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  AuthRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  Future<void> _storeAccessToken(String token) async {
    await Future.wait([
      _cacheService.put(AppConstants.accessToken, token),
      PrefsHelper.setString(legacy_constants.AppConstants.bearerToken, token),
    ]);
  }

  // ─── Register ────────────────────────────

  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String role,
    required String password,
    String? phone,
    String? dob,
    String? referredByCode,
    String? tenantId,
    String? tenantRole,
    String? accessCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'gender': gender,
        'role': role,
      };
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      if (dob != null && dob.isNotEmpty) body['dob'] = dob;
      if (referredByCode != null && referredByCode.isNotEmpty) {
        body['referredByCode'] = referredByCode.toUpperCase();
      }
      if (tenantId != null && tenantId.isNotEmpty) {
        body['tenantId'] = tenantId;
        body['tenantRole'] = tenantRole;
        body['accessCode'] = accessCode;
      }
      debugPrint('🌐 [AuthRepository.register] POST ${ApiConstants.register}');
      debugPrint('   Payload: ${body.map((k, v) => MapEntry(k, (k == 'password' || k == 'accessCode') ? '***' : v))}');

      final response = await _apiService.post(
        ApiConstants.register,
        data: body,
      );

      debugPrint('🌐 [AuthRepository.register] Response status: ${response.statusCode}');
      debugPrint('   Response data: ${response.data}');

      final dynamic dataMap = response.data is Map ? response.data['data'] : null;
      final String token = (dataMap is Map ? dataMap['token'] : null)?.toString() ??
          (response.data is Map ? response.data['token'] : null)?.toString() ??
          '';

      if (token.isEmpty) {
        debugPrint('⚠️ [AuthRepository.register] No token found in response payload: ${response.data}');
      }

      await Future.wait([
        if (token.isNotEmpty) _cacheService.put(AppConstants.otpToken, token),
        _cacheService.put(AppConstants.cacheUserGender, gender.toLowerCase()),
      ]);

      return token;
    } on AppException catch (e, st) {
      debugPrint('🔴 [AuthRepository.register] AppException: $e\n$st');
      rethrow;
    } catch (e, st) {
      debugPrint('🔴 [AuthRepository.register] Unexpected error: $e\n$st');
      throw UnknownException(e.toString());
    }
  }

  // ─── Login ───────────────────────────────

  Future<LoginResultModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
        options: ApiService.withoutAuth,
      );

      final responseData = response.data?['data'];
      final result = LoginResultModel.fromJson(
        Map<String, dynamic>.from(responseData ?? {}),
      );
      final userRole = responseData?['user']?['role']?.toString();
      final tenantScope = result.tenantScope;

      if (result.token.isEmpty) {
        throw UnknownException('Access token not found');
      }

      await Future.wait([
        _storeAccessToken(result.token),
        _cacheService.put('cacheUserEmail', email.toLowerCase()),
        if (userRole != null)
          _cacheService.put(AppConstants.cacheUserRole, userRole),
        _cacheService.put(
          'gymAdminTenantIds',
          tenantScope?.gymAdminTenantIds ?? const <String>[],
        ),
        _cacheService.put(
          'tenantCapabilities',
          tenantScope?.capabilities ?? const <String>[],
        ),
      ]);

      return result;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final serverMsg = (e.response?.data is Map)
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      if (statusCode == 401) throw UnAuthorizedException(serverMsg);
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NoInternetException();
      }
      throw UnknownException(serverMsg ?? e.message ?? 'Network error');
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

  Future<bool> otpVerify({required String otp, String? requiredTenantId}) async {
    try {
      final token = await _cacheService.get(AppConstants.otpToken);
      final response = await _apiService.post(
        ApiConstants.otpVerify,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'otp': otp},
      );

      final responseData = response.data?['data'];
      final result = LoginResultModel.fromJson(
        Map<String, dynamic>.from(responseData ?? {}),
      );
      final accessToken = result.token;
      final userRole = responseData?['role']?.toString() ?? responseData?['user']?['role']?.toString();
      final tenantScope = result.tenantScope;

      if (requiredTenantId != null &&
          tenantScope?.tenantId != requiredTenantId) {
        throw UnknownException('Verified gym access could not be confirmed');
      }

      if (accessToken.isEmpty) {
        throw UnknownException('Access token not found');
      }

      await Future.wait([
        _storeAccessToken(accessToken),
        if (userRole != null)
          _cacheService.put(AppConstants.cacheUserRole, userRole),
        _cacheService.put(
          'gymAdminTenantIds',
          tenantScope?.gymAdminTenantIds ?? const <String>[],
        ),
        _cacheService.put('tenantId', tenantScope?.tenantId ?? ''),
        _cacheService.put(
          'tenantCapabilities',
          tenantScope?.capabilities ?? const <String>[],
        ),
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
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );

      final accessToken = response.data?['data']?['accessToken'];

      if (accessToken != null) {
        await _storeAccessToken(accessToken.toString());
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── Delete Account ──────────────────────

  Future<void> deleteAccount() async {
    try {
      await _apiService.delete(ApiConstants.accountDelete);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }



  // ─── Trainer Profile  ────────────────────────────
  Future<void> registerTrainer(TrainerProfileModel data) async {
    try {
      await _apiService.post(
        ApiConstants.trainerProfile,
        data: data.toJson(),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }


  // ─── User Profile  ────────────────────────────
  Future<void> registerUser(UserProfileModel data) async {
    try {
      await _apiService.post(
        ApiConstants.userOnboarding,
        data: data.toJson(),
      );
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

  /// Returns the email cached at login — used to restore admin mode on restart.
  String? getEmail() {
    return _cacheService.get<String>('cacheUserEmail');
  }

  String? getGender() {
    return _cacheService.get<String>(AppConstants.cacheUserGender);
  }

  bool isLoggedIn() {
    return _cacheService.containsKey(AppConstants.accessToken);
  }

  // ─── Logout ──────────────────────────────

  Future<void> logout() async {
    await Future.wait([
      _cacheService.clear(),
      PrefsHelper.remove(legacy_constants.AppConstants.bearerToken),
    ]);
  }
}
