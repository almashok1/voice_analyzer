import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:voice_analyzer/model/user_model.dart';
import 'package:voice_analyzer/repository/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository});
  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      final bool isAuthorized = await userRepository.isAuthorized();
      if (isAuthorized) yield AuthenticationAuthenticated();
      else yield AuthenticationUnauthenticated(0);
    }
    if (event is SwapToRegister) {
      yield AuthenticationUnauthenticated(1);
    }

    if (event is SwapToLogin) {
      yield AuthenticationUnauthenticated(0);
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.saveUser(user: event.user);
      yield AuthenticationAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      try{
        await userRepository.deleteUser();
      } catch (e) {
        yield AuthenticationUnauthenticated(0);
      }
      yield AuthenticationUnauthenticated(0);
    }
  }
}
