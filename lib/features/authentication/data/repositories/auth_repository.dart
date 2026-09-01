import 'package:dio/dio.dart';
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
    String? referredByCode,
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
      if (referredByCode != null && referredByCode.isNotEmpty) {
        body['referredByCode'] = referredByCode.toUpperCase();
      }
      final response = await _apiService.post(
        ApiConstants.register,
        data: body,
      );

      final token = response.data?['data']['token'];

      await Future.wait([
        _cacheService.put(AppConstants.otpToken, token),
        _cacheService.put(AppConstants.cacheUserGender, gender.toLowerCase()),
      ]);

      return token;
    } on AppException {
      rethrow;
    } catch (e) {
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
      );

      final responseData = response.data?['data'];
      final result = LoginResultModel.fromJson(
        Map<String, dynamic>.from(responseData ?? {}),
      );
      final userRole = responseData?['user']?['role']?.toString();

      if (result.token.isEmpty) {
        throw UnknownException('Access token not found');
      }

      await Future.wait([
        _storeAccessToken(result.token),
        _cacheService.put('cacheUserEmail', email.toLowerCase()),
        if (userRole != null)
          _cacheService.put(AppConstants.cacheUserRole, userRole),
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
        _storeAccessToken(accessToken),
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
