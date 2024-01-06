import 'package:adopt_animal/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository{
  Future<void> googleAuth();
  Future<void> getCreateCurrentUser(UserEntity user);
  Future<bool> isSignIn();
  Future<void> signIn(UserEntity user);
  Future<void> signUp(UserEntity user);
  Future<void> signOut();
  Future<void> getUpdateUser(UserEntity user);
  Future<String> getCurrentUId();
  Stream<List<UserEntity>> getAllUsers(UserEntity user);
  Stream<List<UserEntity>> getSingleUser(UserEntity user);
}