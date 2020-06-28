import 'package:flutter/material.dart';
import 'package:voice_analyzer/blocs/emojis_bloc/emojis_bloc.dart';
import 'package:voice_analyzer/model/record_date.dart';
import 'package:voice_analyzer/repository/user_repository.dart';
import 'package:voice_analyzer/screens/emoji_stats.dart';
import 'package:voice_analyzer/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:voice_analyzer/util/utils.dart';
import 'package:voice_analyzer/widgets/slide_indexed_stack.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool _statTapped = false;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecordDate>(
      create: (context) => RecordDate(),
      builder: (context, _) => Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SlideIndexedStack(
          index: _selectedIndex,
          duration: Duration(milliseconds: 450),
          children: <Widget>[
            HomeScreen(),
            BlocProvider(
              create: (context) => EmojisBloc()..add(EmojisLoad()),
              child: EmojiStats(),
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
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('Главная'),
              ),
              BottomNavigationBarItem(
                icon: Showcase(
                  key: Provider.of<RecordDate>(context, listen: false).four,
                  description: "Нажмите на\nстатистику",
                  disposeOnTap: true,
                  onTargetClick: () async {
                    _selectedIndex = 1;
                    await _onTapAfterShowCase(context);
                  },
                  child: Icon(Icons.equalizer),
                ),
                title: Text('Статистика'),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
            onTap: (int index) async {
              _selectedIndex = index;
              await _onTapAfterShowCase(context);
            },
          ),
        ),
      ),
    );
  }

  Future _onTapAfterShowCase(BuildContext context) async {
    if (!_statTapped && await UserRepository.isFirstOpened()) {
      ShowCaseWidget.of(context).startShowCase([
        Provider.of<RecordDate>(context, listen: false).six,
        Provider.of<RecordDate>(context, listen: false).seven,
        Provider.of<RecordDate>(context, listen: false).eight,
      ]);
      _statTapped = true;
    }
    setState(() {});
    UserRepository.setFirstOpened(false);
    askForPermissions();
  }
}
