import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voice_analyzer/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voice_analyzer/phoneCallListener.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_analyzer/repository/user_repository.dart';
import 'package:voice_analyzer/screens/app.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
  }
}

int id;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userRepository = UserRepository();
  id = await UserRepository.getId();
  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context) {
        return AuthenticationBloc(userRepository: userRepository)
          ..add(AppStarted());
      },
      child: App(userRepository: userRepository),
    ),
  );

  print(id);

  var channel = const MethodChannel('com.example/background_service');
  var callbackHandle = PluginUtilities.getCallbackHandle(backgroundMain);
  var callback =
      await channel.invokeMethod('startService', callbackHandle.toRawHandle());
}

void backgroundMain() {
  WidgetsFlutterBinding.ensureInitialized();
  PhoneCallListener.listenPhoneCallState();
}
