part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

class Authenticated extends AuthState {
  final String uid;

  Authenticated({required this.uid});

  @override
  List<Object> get props => [uid];
}

class UnAuthenticated extends AuthState {
  @override
  List<Object> get props => [];
}

class CredentialLoading extends AuthState {
  @override
  List<Object> get props => [];
}

class CredentialSuccess extends AuthState {
  @override
  List<Object> get props => [];
}

class CredentialFailure extends AuthState {
  final String? message;

  CredentialFailure({this.message});

  @override
  List<Object> get props => [message ?? ""];
}
