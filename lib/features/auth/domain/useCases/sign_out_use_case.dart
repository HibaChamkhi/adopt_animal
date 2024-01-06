
import '../repository/auth_repository_impl.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase({required this.repository});

  Future<void> call()async{
    return repository.signOut();
  }
}