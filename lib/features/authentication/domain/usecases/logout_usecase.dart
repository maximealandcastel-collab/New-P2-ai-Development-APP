import 'package:pler_to_pler_app/features/authentication/domain/repositories/auth_repository.dart';

/// Use Case: Logout
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}
