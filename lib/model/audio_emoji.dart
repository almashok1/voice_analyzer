import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:audioplayers/audioplayers.dart';

class AudioEmoji extends ChangeNotifier {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayer advancedPlayer;

  AudioEmoji() : advancedPlayer = AudioPlayer(){
    advancedPlayer.onAudioPositionChanged.listen((event) {
      position = event;
    });
    advancedPlayer.onDurationChanged.listen((event) {
      duration = event;
    });
  }

  Future<int> getDuration() async {
    return await advancedPlayer.getDuration();
  }

  Duration get duration => _duration;

  Duration get position => _position;

  set duration(Duration d) {
    _duration = d;
    notifyListeners();
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    advancedPlayer.seek(newDuration);
    notifyListeners();
  }

  set position(Duration p) {
    _position = p;
    notifyListeners();
  }
}
