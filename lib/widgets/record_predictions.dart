import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_analyzer/model/audio_emoji.dart';
import 'package:voice_analyzer/model/emojis_model.dart';
import 'package:voice_analyzer/util/utils.dart';

class RecordPredictions extends StatefulWidget {
  final String filePath;
  final EmojisModel data;

  const RecordPredictions({Key key, this.filePath, this.data})
      : super(key: key);
  @override
  _RecordPredictionsState createState() => _RecordPredictionsState();
}

class _RecordPredictionsState extends State<RecordPredictions> {
  final Map<String, List> _emotions = {
    "anger": [null, null, Colors.redAccent],
    "scared": [null, null, Colors.purple],
    "happy": [null, null, Colors.blue],
    "sadness": [null, null, Colors.pink],
    "neutral": [null, null, Colors.grey],
    "disgust": [null, null, Colors.lime],
    "surprised": [null, null, Colors.green],
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioEmoji>(
      builder: (context, audioEmoji, _) => Container(
        child: Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  children: prediction(audioEmoji),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: _buildEmotionsData(audioEmoji),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEmotionsData(AudioEmoji audioEmoji) {
    List<Widget> list = [];
    _emotions.forEach((key, value) {
      list.add(
        Container(
          padding: const EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value[2],
                  boxShadow: value[0] != null &&
                          value[1] != null &&
                          (value[0] as int) <= audioEmoji.position.inSeconds &&
                          audioEmoji.position.inSeconds <= (value[1] as int)
                      ? [BoxShadow(blurRadius: 10.0, color: value[2] as Color)]
                      : null,
                ),
                height: 40.0,
              ),
              Text(emotionTranslate[key]),
            ],
          ),
        ),
      );
    });
    return list;
  }

  List<Widget> prediction(AudioEmoji audioEmoji) {
    List<Widget> list = [];
    int lastValue = 0;
    for (var i in widget.data.emotionData.data) {
      if (i.first.first > lastValue) {
        list.add(
          Expanded(
            flex: i.first.first - lastValue,
            child: Container(
              height: 50.0,
              color: Colors.white,
            ),
          ),
        );
      }
      list.add(
        Expanded(
          flex: i.first.last - i.first.first,
          child: Container(
            height: 50.0,
            decoration: BoxDecoration(
              color: _emotions[i.last][2] as Color,
              boxShadow: i.first.first <= audioEmoji.position.inSeconds &&
                      audioEmoji.position.inSeconds <= i.first.last
                  ? [
                      BoxShadow(
                          blurRadius: 10.0,
                          color: _emotions[i.last][2] as Color)
                    ]
                  : null,
            ),
          ),
        ),
      );
      _emotions[i.last][0] = i.first.first;
      _emotions[i.last][1] = i.first.last;
      lastValue = i.first.last;
    }
    return list.isEmpty ? [Container(child: Text('Нет данных'))] : list;
  }
}
