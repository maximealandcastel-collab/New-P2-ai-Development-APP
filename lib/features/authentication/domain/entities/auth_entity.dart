import 'package:pler_to_pler_app/features/authentication/domain/entities/user_entity.dart';

/// Domain Entity for Authentication Response
class AuthEntity {
  final String? token;
  final String? refreshToken;
  final UserEntity? user;
  final String? message;

  AuthEntity({
    this.token,
    this.refreshToken,
    this.user,
    this.message,
  });
}
