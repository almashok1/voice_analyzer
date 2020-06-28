import 'package:flutter/material.dart';
import 'package:voice_analyzer/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voice_analyzer/blocs/register_bloc/register_bloc.dart';
import 'package:voice_analyzer/repository/user_repository.dart';
import 'package:voice_analyzer/widgets/register_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatelessWidget {
  final UserRepository userRepository;

  RegisterPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  void _onPressed(BuildContext context) {
    BlocProvider.of<AuthenticationBloc>(context).add(SwapToLogin());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _onPressed(context);
          },
        ),
        title: Text('Регистрация'),
      ),
      body: BlocProvider(
        create: (context) {
          return RegisterBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            userRepository: userRepository,
          );
        },
        child: RegisterForm(
          userRepository: userRepository,
        ),
      ),
    );
  }
}
