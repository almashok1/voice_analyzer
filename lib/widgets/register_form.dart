import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_analyzer/blocs/register_bloc/register_bloc.dart';
import 'package:voice_analyzer/repository/user_repository.dart';
import 'package:voice_analyzer/util/utils.dart';

class RegisterForm extends StatefulWidget {
  final UserRepository userRepository;

  const RegisterForm({Key key, @required this.userRepository})
      : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _onRegisterButtonPressed() {
      if (_formKey.currentState.validate()) {
        BlocProvider.of<RegisterBloc>(context).add(RegisterButtonPressed(
          username: _usernameController.text,
          password: _passwordController.text,
          email: _emailController.text,
        ));
      }
    }

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) async {
        if (state is RegisterFailure) {
          widget.userRepository.deleteUser();
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("${state.error}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Container(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Введите имя пользователя';
                        }
                        if (value.length < 4)
                          return 'Имя пользователя должен содержать не менее 3 символов';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'имя пользователя',
                        icon: Icon(Icons.person),
                      ),
                      controller: _usernameController,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (!validateEmail(value))
                          return 'Введите правильный адрес электронной почты';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'электронная почта',
                        icon: Icon(Icons.email),
                      ),
                      controller: _emailController,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.length < 8)
                          return 'Пароль должен содержать не менее 8 символов';
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'пароль', icon: Icon(Icons.security)),
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.22,
                      child: Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: RaisedButton(
                          onPressed: state is! RegisterLoading
                              ? _onRegisterButtonPressed
                              : null,
                          child: Text(
                            'Зарегистрировать',
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                          shape: StadiumBorder(),
                        ),
                      ),
                    ),
                    Container(
                      child: state is RegisterLoading
                          ? CircularProgressIndicator()
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
