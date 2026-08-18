import 'package:pler_to_pler_app/features/authentication/domain/entities/auth_entity.dart';
import 'package:pler_to_pler_app/features/authentication/domain/repositories/auth_repository.dart';

/// Use Case: Login
/// Single responsibility: Execute login business logic
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthEntity> call({
    required String email,
    required String password,
    required String role,
  }) async {
    // Business logic validation can be added here
    if (email.isEmpty || password.isEmpty) {
      throw const FormatException('Email and password are required');
    }

    return await repository.login(
      email: email,
      password: password,
      role: role,
    );
  }
}
