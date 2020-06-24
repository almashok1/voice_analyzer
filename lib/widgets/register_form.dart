import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_analyzer/blocs/authentication_bloc/authentication_bloc.dart';
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
        // if (state is RegisteredSuccesfully) {
        //   Navigator.of(context).pop();
        // }
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
                          return 'Enter some text';
                        }
                        if (value.length < 4)
                          return 'Enter a username length longer than 3';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'username',
                        icon: Icon(Icons.person),
                      ),
                      controller: _usernameController,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (!validateEmail(value))
                          return 'Enter a correct email address';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'email',
                        icon: Icon(Icons.email),
                      ),
                      controller: _emailController,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.length < 8)
                          return 'Password length must be loger than 8';
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'password', icon: Icon(Icons.security)),
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
                            'Register',
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
