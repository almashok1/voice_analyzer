import 'package:flutter/material.dart';
import 'package:voice_analyzer/model/audio_emoji.dart';
import 'package:voice_analyzer/model/emojis_model.dart';
import 'package:provider/provider.dart';
import 'package:voice_analyzer/util/utils.dart';
import 'package:voice_analyzer/widgets/record_predictions.dart';

class RecordStat extends StatefulWidget {
  final String filePath;
  final EmojisModel data;

  const RecordStat({Key key, this.filePath, this.data}) : super(key: key);
  @override
  _RecordStatState createState() => _RecordStatState();
}

class _RecordStatState extends State<RecordStat> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _btn(String txt, VoidCallback onPressed) {
    return ButtonTheme(
      minWidth: 48.0,
      child: Container(
        height: 60.0,
        width: 150.0,
        padding: const EdgeInsets.all(10.0),
        child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(txt),
            color: Theme.of(context).buttonColor,
            textColor: Colors.white,
            onPressed: onPressed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioEmoji>(builder: (context, audioEmoji, _) {
      return WillPopScope(
        onWillPop: () {
          audioEmoji.advancedPlayer.stop();
          return Future.value(true);
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(title: Text("Record Stats")),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _btn(
                            'Play',
                            () => audioEmoji.advancedPlayer
                                .play(widget.filePath)),
                        _btn('Pause', () => audioEmoji.advancedPlayer.pause()),
                      ],
                    ),
                    Center(
                      child: Container(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            //slider modifications
                            activeTrackColor: Theme.of(context).accentColor,
                            inactiveTrackColor: Colors.black,
                            trackHeight: 6.0,
                            thumbColor: Theme.of(context).primaryColor,
                          ),
                          child: Slider(
                            min: 0.0,
                            max: audioEmoji.duration.inSeconds.toDouble(),
                            value: audioEmoji.position.inSeconds.toDouble(),
                            onChanged: (value) {
                              audioEmoji.seekToSecond(value.toInt());
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "${placeZeroIfNeeded(audioEmoji.position.inMinutes)}:${placeZeroIfNeeded(audioEmoji.position.inSeconds % 60)}",
                        style: TextStyle(
                            color: Theme.of(context).textSelectionColor,
                            fontSize: 24.0),
                      ),
                    ),
                  ],
                ),
              ),
              ChangeNotifierProvider<AudioEmoji>.value(
                value: audioEmoji,
                builder: (context, _) => RecordPredictions(
                  data: widget.data,
                  filePath: widget.filePath,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
