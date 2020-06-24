import 'package:flutter/material.dart';
import 'package:voice_analyzer/background_listen.dart';
import 'package:voice_analyzer/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voice_analyzer/repository/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voice_analyzer/screens/home.dart';
import 'package:voice_analyzer/screens/login_page.dart';
import 'package:voice_analyzer/screens/register_page.dart';
import 'package:voice_analyzer/screens/splash_screen.dart';
import 'package:voice_analyzer/widgets/loading_indicator.dart';

class App extends StatelessWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        backgroundColor: Color(0xff342b38),
        primaryColor: Color(0xffc70039),
        accentColor: Color(0xfff37121),
        buttonColor: Color(0xffc70039),
        textSelectionColor: Color(0xfff4f4f4),
        textTheme: TextTheme(headline6: TextStyle(color: Color(0xfff4f4f4))),
        brightness: Brightness.dark,
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationUninitialized) {
            return SplashScreen();
          }
          if (state is AuthenticationAuthenticated) {
            return BackgroundListen(child: Home());
          }
          if (state is AuthenticationUnauthenticated) {
            return IndexedStack(
              index: state.indexedStack,
              children: <Widget>[
                LoginPage(userRepository: userRepository,),
                RegisterPage(userRepository: userRepository,),
              ],
            );
          }
          if (state is AuthenticationLoading) {
            return LoadingIndicator();
          }
          return LoadingIndicator();
        },
      ),
    );
  }
}