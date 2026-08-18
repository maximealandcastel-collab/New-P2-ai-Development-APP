import 'package:pler_to_pler_app/core/utils/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/utils/helpers/hive_cache_helper.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/auth_model.dart';
import 'package:pler_to_pler_app/features/authentication/data/models/user_model.dart';
import 'package:pler_to_pler_app/services/network/dio_api_client.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';

/// Remote Data Source - Handles API calls
/// This is where the actual HTTP requests happen
abstract class AuthRemoteDataSource {
  Future<AuthModel> login({
    required String email,
    required String password,
    required String role,
  });

  Future<AuthModel> register({
    required String email,
    required String password,
    required String role,
  });

  Future<AuthModel> verifyOtp({
    required String email,
    required String otp,
  });

  Future<void> forgotPassword({required String email});

  Future<UserModel> getCurrentUser();

  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? profilePicture,
  });
}

/// Implementation of Remote Data Source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<AuthModel> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await NetworkCaller.instance.postRequest(
      url: ApiUrls.baseUrl + ApiUrls.login,
      body: {
        'email': email,
        'password': password,
        'role': role.toLowerCase(),
      },
    );

    if (response.isSuccess) {
      return AuthModel.fromJson(response.responseBody);
    } else {
      throw Exception(response.errorMassage);
    }
  }

  @override
  Future<AuthModel> register({
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await NetworkCaller.instance.postRequest(
      url: ApiUrls.baseUrl + ApiUrls.register,
      body: {
        'email': email,
        'password': password,
        'role': role.toLowerCase(),
      },
    );

    if (response.isSuccess) {
      return AuthModel.fromJson(response.responseBody);
    } else {
      throw Exception(response.errorMassage);
    }
  }

  @override
  Future<AuthModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await NetworkCaller.instance.postRequest(
      url: ApiUrls.baseUrl + ApiUrls.verifyOtp,
      body: {
        'email': email,
        'otp': otp,
      },
    );

    if (response.isSuccess) {
      return AuthModel.fromJson(response.responseBody);
    } else {
      throw Exception(response.errorMassage);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    final response = await NetworkCaller.instance.postRequest(
      url: ApiUrls.baseUrl + ApiUrls.forgetPassword,
      body: {'email': email},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMassage);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    // Try to get cached data first
    final cachedData = await HiveCacheHelper.getWithExpiration<Map<String, dynamic>>(
      key: AppConstants.cacheUserProfile,
    );

    if (cachedData != null) {
      return UserModel.fromJson(cachedData);
    }

    // Fetch from API if no cache
    final response = await NetworkCaller.instance.getRequest(
      url: ApiUrls.baseUrl + ApiUrls.userMe,
    );

    if (response.isSuccess && response.responseBody != null) {
      final userModel = UserModel.fromJson(response.responseBody);
      
      // Cache the user profile data with expiration
      await HiveCacheHelper.saveWithExpiration(
        key: AppConstants.cacheUserProfile,
        value: userModel.toJson(),
        expireInSeconds: AppConstants.cacheUserProfileExpiration,
      );
      
      return userModel;
    } else {
      throw Exception(response.errorMassage);
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? profilePicture,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (bio != null) body['bio'] = bio;
    if (profilePicture != null) body['profilePicture'] = profilePicture;

    final response = await NetworkCaller.instance.postRequest(
      url: ApiUrls.baseUrl + ApiUrls.updateProfile,
      body: body,
    );

    if (response.isSuccess) {
      final userModel = UserModel.fromJson(response.responseBody);
      
      // Update cache with new profile data
      await HiveCacheHelper.saveWithExpiration(
        key: AppConstants.cacheUserProfile,
        value: userModel.toJson(),
        expireInSeconds: AppConstants.cacheUserProfileExpiration,
      );
      
      return userModel;
    } else {
      throw Exception(response.errorMassage);
    }
  }
}
