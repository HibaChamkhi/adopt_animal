import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository_impl.dart';
import '../dataSources/auth_remote_data_sources.dart';

class AuthRepositoryImpl implements AuthRepository {

  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});


  @override
  Stream<List<UserEntity>> getAllUsers(UserEntity user) =>
      remoteDataSource.getAllUsers(user);

  @override
  Future<void> getCreateCurrentUser(UserEntity user)async =>
      remoteDataSource.getCreateCurrentUser(user);

  @override
  Future<String> getCurrentUId() async =>
      remoteDataSource.getCurrentUId();

  @override
  Stream<List<UserEntity>> getSingleUser(UserEntity user) =>
      remoteDataSource.getSingleUser(user);

  @override
  Future<void> getUpdateUser(UserEntity user) async =>
      remoteDataSource.getUpdateUser(user);

  @override
  Future<void> googleAuth() async =>
      remoteDataSource.googleAuth();

  @override
  Future<bool> isSignIn() async =>
      remoteDataSource.isSignIn();

  @override
  Future<void> signIn(UserEntity user) async =>
      remoteDataSource.signIn(user);

  @override
  Future<void> signOut() async =>
      remoteDataSource.signOut();

  @override
  Future<void> signUp(UserEntity user) async =>
      remoteDataSource.signUp(user);

}