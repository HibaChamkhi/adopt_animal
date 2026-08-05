import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/useCases/Is_signIn_use_case.dart';
import '../../../domain/useCases/get_current_uid_use_case.dart';
import '../../../domain/useCases/sign_out_use_case.dart';
import '../../../domain/useCases/signin_use_case.dart';
import '../../../domain/useCases/signup_use_case.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final IsSignInUseCase isSignInUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUIDUseCase getCurrentUIDUseCase;

  AuthCubit(
      {required this.signUpUseCase,
      required this.signInUseCase,
      required this.isSignInUseCase,
      required this.signOutUseCase,
      required this.getCurrentUIDUseCase})
      : super(AuthInitial());

  Future<void> signInSubmit({
    required String email,
    required String password,
  }) async {
    emit(CredentialLoading());
    try {
      await signInUseCase.call(UserEntity(
        email: email,
        password: password,
      ));
      emit(CredentialSuccess());
    } on SocketException catch (_) {
      emit(CredentialFailure(
          message: "No internet connection. Please try again."));
    } on FirebaseAuthException catch (e) {
      // Some firebase_auth versions authenticate the user but still throw.
      if (await _safeIsSignedIn()) {
        emit(CredentialSuccess());
      } else {
        emit(CredentialFailure(message: _authErrorMessage(e)));
      }
    } catch (_) {
      // Known firebase_auth type-cast bug: auth succeeds but the plugin throws
      // while unwrapping the result. Trust the real auth state before failing.
      if (await _safeIsSignedIn()) {
        emit(CredentialSuccess());
      } else {
        emit(CredentialFailure(
            message: "Something went wrong. Please try again."));
      }
    }
  }

  Future<void> signUpSubmit({required UserEntity user}) async {
    emit(CredentialLoading());
    try {
      await signUpUseCase.call(user);
      emit(CredentialSuccess());
    } on SocketException catch (_) {
      emit(CredentialFailure(
          message: "No internet connection. Please try again."));
    } on FirebaseAuthException catch (e) {
      if (await _safeIsSignedIn()) {
        emit(CredentialSuccess());
      } else {
        emit(CredentialFailure(message: _authErrorMessage(e)));
      }
    } catch (_) {
      if (await _safeIsSignedIn()) {
        emit(CredentialSuccess());
      } else {
        emit(CredentialFailure(
            message: "Something went wrong. Please try again."));
      }
    }
  }

  Future<bool> _safeIsSignedIn() async {
    try {
      return await isSignInUseCase.call();
    } catch (_) {
      return false;
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "That email address looks invalid.";
      case 'user-not-found':
        return "No account found for that email.";
      case 'wrong-password':
      case 'invalid-credential':
        return "Incorrect email or password.";
      case 'user-disabled':
        return "This account has been disabled.";
      case 'email-already-in-use':
        return "That email is already registered. Try logging in.";
      case 'weak-password':
        return "Password is too weak (use at least 6 characters).";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      case 'operation-not-allowed':
        return "Email/password sign-in is not enabled for this project.";
      case 'network-request-failed':
        return "Network error. Please check your connection.";
      default:
        return e.message ?? "Authentication failed. Please try again.";
    }
  }

  Future<void> appStarted() async {
    try {
      final isSignIn = await isSignInUseCase.call();

      if (isSignIn == true) {
        final uid = await getCurrentUIDUseCase.call();

        emit(Authenticated(uid: uid));
      } else {
        emit(UnAuthenticated());
      }
    } catch (_) {
      emit(UnAuthenticated());
    }
  }

  Future<void> loggedIn() async {
    try {
      final uid = await getCurrentUIDUseCase.call();

      emit(Authenticated(uid: uid));
    } catch (_) {
      emit(UnAuthenticated());
    }
  }

  Future<void> loggedOut() async {
    try {
      await signOutUseCase.call();
      emit(UnAuthenticated());
    } catch (_) {
      emit(UnAuthenticated());
    }
  }
}
