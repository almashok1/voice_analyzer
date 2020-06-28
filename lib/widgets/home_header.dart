import 'package:flutter/material.dart';
import 'package:voice_analyzer/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voice_analyzer/repository/user_repository.dart';

class HomeHeader extends StatelessWidget {
  final AuthenticationBloc bloc;
  const HomeHeader({Key key, this.bloc}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 200.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50.0),
              bottomRight: Radius.circular(50.0),
            ),
          ),
        ),
        Positioned(
          right: 30.0,
          top: 40.0,
          child: IconButton(
            onPressed: () => bloc.add(LoggedOut()),
            icon: Icon(Icons.exit_to_app)
          ),
        ),
        Positioned(
          right: 50.0,
          bottom: 50.0,
          left: 50.0,
          child: Container(
            child: FutureBuilder(
              future: UserRepository.getUserName(),
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Text("Приветствую, ${snapshot.data}",
                      style: TextStyle(fontSize: 25.0));
                } else
                  return Text("");
              },
            ),
          ),
        ),
      ],
    );
  }
}
