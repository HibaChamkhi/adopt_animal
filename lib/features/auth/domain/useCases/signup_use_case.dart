

import '../entities/user_entity.dart';
import '../repository/auth_repository_impl.dart';

class SignInUseCase{
  final AuthRepository repository;

  SignInUseCase({required this.repository});

  Future<void> call(UserEntity user){
    return repository.signIn(user);
  }
}