
import '../repository/auth_repository_impl.dart';

class IsSignInUseCase {

  final AuthRepository repository;

  IsSignInUseCase({required this.repository});

  Future<bool> call()async{
    return repository.isSignIn();
  }
}