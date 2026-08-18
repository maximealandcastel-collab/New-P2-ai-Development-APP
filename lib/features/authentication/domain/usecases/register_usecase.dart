import 'package:pler_to_pler_app/features/authentication/domain/entities/auth_entity.dart';
import 'package:pler_to_pler_app/features/authentication/domain/repositories/auth_repository.dart';

/// Use Case: Register
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthEntity> call({
    required String email,
    required String password,
    required String role,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw const FormatException('Email and password are required');
    }

    return await repository.register(
      email: email,
      password: password,
      role: role,
    );
  }
}
