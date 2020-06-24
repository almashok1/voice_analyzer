import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:voice_analyzer/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voice_analyzer/repository/user_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  RegisterBloc({
    @required this.userRepository, 
    @required this.authenticationBloc
  });

  @override
  RegisterState get initialState => RegisterInitial();

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is RegisterButtonPressed) {
      yield RegisterInitial();

      try {
        if (event.username.isEmpty || event.email.isEmpty || event.password.isEmpty)
          throw Exception('Empty form');
        await userRepository.createUser(
          username: event.username,
          password: event.password,
          email: event.email
        );

        final user = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );
        authenticationBloc.add(LoggedIn(user: user));
        yield RegisteredSuccesfully();
      } catch (e) {
        yield RegisterFailure(error: e.toString());
      }
    }
  }
}
