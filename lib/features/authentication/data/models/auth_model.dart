import 'package:pler_to_pler_app/features/authentication/data/models/user_model.dart';
import 'package:pler_to_pler_app/features/authentication/domain/entities/auth_entity.dart';

/// Data Model for Authentication Response
class AuthModel {
  final String? token;
  final String? refreshToken;
  final UserModel? user;
  final String? message;

  AuthModel({
    this.token,
    this.refreshToken,
    this.user,
    this.message,
  });

  /// Create from JSON (API response)
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] as String? ?? 
             json['accessToken'] as String? ?? 
             json['access_token'] as String?,
      refreshToken: json['refreshToken'] as String? ?? 
                    json['refresh_token'] as String?,
      user: json['user'] != null 
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : json['data'] != null
              ? UserModel.fromJson(json['data'] as Map<String, dynamic>)
              : null,
      message: json['message'] as String? ?? 
               json['msg'] as String?
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
      'message': message,
    };
  }

  /// Convert to Domain Entity
  AuthEntity toEntity() {
    return AuthEntity(
      token: token,
      refreshToken: refreshToken,
      user: user?.toEntity(),
      message: message,
    );
  }
}
