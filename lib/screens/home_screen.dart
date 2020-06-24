import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:voice_analyzer/api/api_connection.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:voice_analyzer/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:voice_analyzer/repository/user_repository.dart';
import 'package:voice_analyzer/util/utils.dart';
import 'package:voice_analyzer/widgets/home_header.dart';
import 'package:path/path.dart' as path;
import 'package:voice_analyzer/widgets/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  ApiConnection apiConnection = ApiConnection();

  bool _isRecording = false;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  AudioPlayer audioPlayer = AudioPlayer();
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    _animationController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[
          HomeHeader(bloc: BlocProvider.of<AuthenticationBloc>(context)),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.symmetric(vertical: 50.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        Theme.of(context).textSelectionColor.withOpacity(0.2),
                  ),
                  child: Column(
                    children: <Widget>[
                      voiceTimer,
                      SizedBox(
                        height: 30.0,
                      ),
                      voiceRecorder,
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: uploadButton,
                  decoration: BoxDecoration(
                      color: Theme.of(context).textSelectionColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 10.0,
                            color: Theme.of(context).textSelectionColor)
                      ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get uploadButton {
    return FlatButton(
      onPressed: () async {
        _askForPermissions();
        File file = await FilePicker.getFile(
          type: FileType.custom,
          allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a'],
        );
        String dir = (await getExternalStorageDirectory()).path;
        String newPath =
            path.join(dir, '${await UserRepository.getUserName()}');
        await Directory(newPath).create();
        newPath =
            path.join(newPath, createRecordPath() + path.extension(file.path));
        File newFile = file.copySync(newPath);
        print(newFile.path);
        try {
          showDialog(
              context: context,
              child: LoadingIndicator(),
              barrierDismissible: false);
          bool isLoaded = await apiConnection.sendToBackEnd(newFile.path);
          if (isLoaded) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text("Successfully loaded, check it from the records"),
                  backgroundColor: Colors.green,
                ),
              );
          }
        } on Exception catch (e) {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).primaryColor,
                title: Text('Error'),
                content: Text(e.toString()),
              );
            },
          );
        }
      },
      child: Text(
        "Upload",
        style: TextStyle(
          color: Theme.of(context).backgroundColor,
          fontSize: 20.0,
        ),
      ),
    );
  }

  Widget get voiceTimer {
    return StreamBuilder<int>(
      stream: _stopWatchTimer.rawTime,
      initialData: _stopWatchTimer.rawTime.value,
      builder: (context, snap) {
        final value = snap.data;
        final displayTime = StopWatchTimer.getDisplayTime(value);
        return Text(
          displayTime.toString(),
          style: TextStyle(color: Colors.white, fontSize: 25),
        );
      },
    );
  }

  Widget get voiceRecorder {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(Icons.keyboard_voice,
            size: 50, color: Theme.of(context).primaryColor.withOpacity(0.9)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).textSelectionColor,
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).textSelectionColor,
                blurRadius: _isRecording ? _animation.value * 1.5 : 0,
                spreadRadius: _isRecording ? _animation.value / 3.0 : 0),
          ],
        ),
      ),
      onLongPressStart: (_) {
        if (!_isRecording) _start();
      },
      onLongPressEnd: (_) {
        if (_isRecording) _stop();
      },
    );
  }

  _start([bool hasTimer = true]) async {
    print(await UserRepository.getId());
    await _askForPermissions();
    if (hasTimer) _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
    if (await AudioRecorder.hasPermissions) {
      final externalPath = await getExternalStorageDirectory();
      final directory = await Directory(
              externalPath.path + '/${await UserRepository.getUserName()}')
          .create();
      String pathN = path.join(directory.path, createRecordPath());
      await AudioRecorder.start(
          path: pathN, audioOutputFormat: AudioOutputFormat.WAV);

      bool isRecording = await AudioRecorder.isRecording;
      _isRecording = isRecording;
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    } else {
      print('no permission');
    }
  }

  static Future<Map<Permission, PermissionStatus>> _askForPermissions() async {
    return await [Permission.microphone, Permission.storage].request();
  }

  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  _stop([bool hasTimer = true]) async {
    var recording = await AudioRecorder.stop();
    bool isRecording = await AudioRecorder.isRecording;
    _isRecording = isRecording;
    if (hasTimer) _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    print('SENDING');
    try {
      showDialog(
          context: context,
          child: LoadingIndicator(),
          barrierDismissible: false);
      bool isLoaded = await apiConnection.sendToBackEnd(recording.path);
      if (isLoaded) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        Scaffold.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text("Successfully loaded, check it from the records"),
              backgroundColor: Colors.green,
            ),
          );
      }
    } on Exception catch (e) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('Error'),
            content: Text(e.toString()),
          );
        },
      );
    }
  }
}
