import 'package:pler_to_pler_app/features/authentication/domain/entities/user_entity.dart';
import 'package:pler_to_pler_app/features/authentication/domain/repositories/auth_repository.dart';

/// Use Case: Get Current User
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserEntity> call() async {
    return await repository.getCurrentUser();
  }
}
