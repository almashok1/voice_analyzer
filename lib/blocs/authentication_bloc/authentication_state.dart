part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationUninitialized extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {}

class AuthenticationUnauthenticated extends AuthenticationState {
  final int indexedStack;
  AuthenticationUnauthenticated(this.indexedStack);

  @override
  List<Object> get props => [indexedStack];
}

class AuthenticationLoading extends AuthenticationState {}
