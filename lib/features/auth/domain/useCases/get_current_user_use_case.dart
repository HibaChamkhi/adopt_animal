import '../entities/user_entity.dart';
import '../repository/auth_repository_impl.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  Future<UserEntity> call() async {
    return await repository.getCurrentUser();
  }
}
