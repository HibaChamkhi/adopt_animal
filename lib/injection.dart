import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'features/auth/data/dataSources/auth_remote_data_sources.dart';
import 'features/auth/data/repository/auth_repository.dart';
import 'features/auth/domain/repository/auth_repository_impl.dart';
import 'features/auth/domain/useCases/Is_signIn_use_case.dart';
import 'features/auth/domain/useCases/get_current_uid_use_case.dart';
import 'features/auth/domain/useCases/sign_out_use_case.dart';
import 'features/auth/domain/useCases/signin_use_case.dart';
import 'features/auth/domain/useCases/signup_use_case.dart';
import 'features/auth/presentation/cubit/auth/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //Cubit or Bloc
  sl.registerFactory<AuthCubit>(() => AuthCubit(
      signInUseCase: sl.call(),
      signUpUseCase: sl.call(),
      isSignInUseCase: sl.call(),
      signOutUseCase: sl.call(),
      getCurrentUIDUseCase: sl.call()));

  //UseCases

  sl.registerLazySingleton<GetCurrentUIDUseCase>(
          () => GetCurrentUIDUseCase(repository: sl.call()));
  sl.registerLazySingleton<IsSignInUseCase>(
          () => IsSignInUseCase(repository: sl.call()));
  sl.registerLazySingleton<SignInUseCase>(
          () => SignInUseCase(repository: sl.call()));
  sl.registerLazySingleton<SignOutUseCase>(
          () => SignOutUseCase(repository: sl.call()));
  sl.registerLazySingleton<SignUpUseCase>(
          () => SignUpUseCase(repository: sl.call()));

  //Repository
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl.call()));

  // RemoteDataSource
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
      fireStore: sl.call(), auth: sl.call(), googleSignIn: sl.call()));

  /// External
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseStorage storage = FirebaseStorage.instance;

  sl.registerLazySingleton(() => auth);
  sl.registerLazySingleton(() => fireStore);
  sl.registerLazySingleton(() => googleSignIn);
  sl.registerLazySingleton(() => storage);
}
