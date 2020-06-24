import 'package:flutter/material.dart';
import 'package:voice_analyzer/blocs/emojis_bloc/emojis_bloc.dart';
import 'package:voice_analyzer/model/record_date.dart';
import 'package:voice_analyzer/screens/emoji_stats.dart';
import 'package:voice_analyzer/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          HomeScreen(),
          BlocProvider(
            create: (context) => EmojisBloc()..add(EmojisLoad()),
            child: ChangeNotifierProvider<RecordDate>(
              create: (context) => RecordDate(),
              child: EmojiStats(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(blurRadius: 2.0, color: Theme.of(context).accentColor)
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).backgroundColor,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.equalizer),
              title: Text('Stats'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
