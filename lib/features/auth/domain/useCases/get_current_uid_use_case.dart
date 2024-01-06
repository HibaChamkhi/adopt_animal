
import '../repository/auth_repository_impl.dart';

class GetCurrentUIDUseCase{
  final AuthRepository repository;

  GetCurrentUIDUseCase({required this.repository});
  Future<String> call()async{
    return await repository.getCurrentUId();
  }
}