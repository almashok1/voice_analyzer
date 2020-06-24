import 'dart:io';
import 'package:phone_state_i/phone_state_i.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:voice_analyzer/api/api_connection.dart';
import 'package:voice_analyzer/repository/user_repository.dart';
import 'package:voice_analyzer/util/utils.dart';
import 'package:path/path.dart' as path;

class PhoneCallListener {
  static int id;
  static final ApiConnection _apiConnection = ApiConnection();
  static final UserRepository _userRepository = UserRepository();

  static void listenPhoneCallState() async {
    if (await _userRepository.isAuthorized()) {
      phoneStateCallEvent.listen((event) {
        print(event.stateC);
        if (event.stateC == 'true')
          _startForListen();
        else if (event.stateC == 'false') {
          _stopForListen();
        }
      });
    }
  }

  static void _startForListen() async {
    if (await AudioRecorder.hasPermissions) {
      final externalPath = await getExternalStorageDirectory();
      final directory = await (Directory(
              path.join(externalPath.path,'${await UserRepository.getUserName()}'))).create();
      String pathN = path.join(directory.path, (createRecordPath()));
      bool isRecording = await AudioRecorder.isRecording;
      if (!isRecording)
        await AudioRecorder.start(
            path: pathN, audioOutputFormat: AudioOutputFormat.WAV);
    } else {
      print('no permission');
    }
  }

  static void _stopForListen() async {
    bool isRecording = await AudioRecorder.isRecording;
    if (isRecording) {
      var recording = await AudioRecorder.stop();
      Future.delayed(Duration(seconds: 2));
      await _apiConnection.sendToBackEnd(recording.path).catchError((_) {});
    }
  }
}
