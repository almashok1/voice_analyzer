import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_analyzer/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voice_analyzer/blocs/login_bloc/login_bloc.dart';
import 'package:voice_analyzer/blocs/register_bloc/register_bloc.dart';
import 'package:voice_analyzer/repository/user_repository.dart';
import 'package:voice_analyzer/screens/register_page.dart';

class LoginForm extends StatefulWidget {
  final UserRepository userRepository;

  const LoginForm({Key key, @required this.userRepository}) : super(key: key);
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  RegisterBloc registerBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    registerBloc = RegisterBloc(
      authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
      userRepository: widget.userRepository,
    );
    _onLoginButtonPressed() {
      if (_formKey.currentState.validate()) {
        BlocProvider.of<LoginBloc>(context).add(LoginButtonPressed(
            username: _usernameController.text,
            password: _passwordController.text));
      }
    }

    _pushToRegisterPage() {
      BlocProvider.of<AuthenticationBloc>(context).add(SwapToRegister());
      // print(context);
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(
      //     builder: (context) => BlocProvider<RegisterBloc>(
      //       create: (context) {
      //         return registerBloc;
      //       },
      //       child: RegisterPage(
      //         userRepository: widget.userRepository,
      //       ),
      //     ),
      //   ),
      // );
      // });
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("${state.error}"),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Container(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter some text';
                        }
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
                        if (value.isEmpty) {
                          return 'Enter some text';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'password', icon: Icon(Icons.lock)),
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    SizedBox(height: 30.0),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.width * 0.14,
                          child: RaisedButton(
                            onPressed: () {
                              _pushToRegisterPage();
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            shape: StadiumBorder(),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.14,
                          height: MediaQuery.of(context).size.width * 0.14,
                          child: RaisedButton(
                              onPressed: state is! LoginLoading
                                  ? _onLoginButtonPressed
                                  : null,
                              child: Icon(Icons.arrow_forward),
                              shape: CircleBorder()),
                        ),
                      ],
                    ),
                    Container(
                      child: state is LoginLoading
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
