import 'package:flutter/material.dart';
import 'package:voice_analyzer/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voice_analyzer/blocs/login_bloc/login_bloc.dart';
import 'package:voice_analyzer/repository/user_repository.dart';
import 'package:voice_analyzer/widgets/login_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Вход'),
      ),
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            userRepository: userRepository,
          );
        },
        child: LoginForm(userRepository: userRepository,),
      ),
    );
  }
}