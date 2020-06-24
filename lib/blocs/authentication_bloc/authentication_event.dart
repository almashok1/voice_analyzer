part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class SwapToRegister extends AuthenticationEvent {}

class SwapToLogin extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final User user;

  const LoggedIn({@required this.user});

  @override
  List<Object> get props => [user];

  @override
  String toString() {
    return 'LoggedIn { ${user.username.toString()} }';
  }
}

class LoggedOut extends AuthenticationEvent {}
