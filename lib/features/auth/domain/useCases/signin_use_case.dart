import '../entities/user_entity.dart';
import '../repository/auth_repository_impl.dart';

class SignUpUseCase{
  final AuthRepository repository;

  SignUpUseCase({required this.repository});

  Future<void> call(UserEntity user){
    return repository.signUp(user);
  }
}