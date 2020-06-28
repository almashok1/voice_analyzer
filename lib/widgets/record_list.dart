import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_analyzer/model/audio_emoji.dart';
import 'package:voice_analyzer/model/emojis_model.dart';
import 'package:voice_analyzer/model/record_date.dart';
import 'package:voice_analyzer/repository/user_repository.dart';
import 'package:voice_analyzer/screens/record_stat.dart';
import 'package:voice_analyzer/util/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RecordList extends StatelessWidget {
  final List<String> recordList;

  const RecordList({Key key, this.recordList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordDate>(builder: (context, recordDate, _) {
      List<String> filteredList = []
        ..addAll(recordList.where((i) => filterDates(i, recordDate)));
      recordDate.filteredRecordList = filteredList;
      return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, ind) {
          return _buildRecordSegment(ind, context, recordDate, filteredList);
        },
      );
    });
  }

  Widget _buildRecordSegment(int ind, BuildContext context,
      RecordDate recordDate, List<String> filteredList) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(flex: 2, child: _numberInCircle(ind, context)),
          Expanded(flex: 5, child: Text(filteredList[ind])),
          Expanded(
            flex: 3,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              color: Theme.of(context).buttonColor,
              onPressed: () async {
                final externalPath = await getExternalStorageDirectory();
                final username = await UserRepository.getUserName();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      EmojisModel data = recordDate.emotionData.singleWhere(
                        (element) => element.name == filteredList[ind],
                        orElse: () => null,
                      );
                      if (data == null) {
                        return Scaffold(
                          body: Container(
                            color: Theme.of(context).backgroundColor,
                            child: Center(
                              child: Text("Данных пока нет"),
                            ),
                          ),
                        );
                      }
                      return ChangeNotifierProvider<AudioEmoji>(
                        create: (context) => AudioEmoji(),
                        builder: (context, _) => RecordStat(
                          filePath: path.join(
                              externalPath.path, username, filteredList[ind]),
                          data: data,
                        ),
                      );
                    },
                  ),
                );
              },
              child: Text("Анализ"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberInCircle(int ind, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(5.0),
      child: Center(
        child: Text("${ind + 1}"),
      ),
    );
  }
}
