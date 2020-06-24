import 'dart:io';

import 'package:flutter/material.dart';
import 'package:voice_analyzer/api/api_connection.dart';
import 'package:voice_analyzer/blocs/emojis_bloc/emojis_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:voice_analyzer/model/record_date.dart';
import 'package:voice_analyzer/repository/user_repository.dart';
import 'package:voice_analyzer/screens/all_stats.dart';
import 'package:voice_analyzer/util/utils.dart';
import 'package:voice_analyzer/widgets/loading_indicator.dart';
import 'package:voice_analyzer/widgets/record_list.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmojiStats extends StatefulWidget {
  @override
  _EmojiStatsState createState() => _EmojiStatsState();
}

class _EmojiStatsState extends State<EmojiStats> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final ApiConnection _apiConnection = ApiConnection();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onRefresh(RecordDate recordDate) async {
    try {
      recordDate.emotionData = await _apiConnection.getAllRecords();
      setState(() {});
    } catch (e) {
      showErrorAlertDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordDate>(
      builder: (context, recordDate, __) => Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: AppBar(
            centerTitle: true,
            flexibleSpace: SafeArea(
              child: Center(
                child: FlatButton(
                  padding: const EdgeInsets.all(12.0),
                  color: Theme.of(context).backgroundColor.withOpacity(0.17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  onPressed: () async {
                    final List<DateTime> picked =
                        await DateRangePicker.showDatePicker(
                      context: context,
                      initialFirstDate: recordDate.firstDate,
                      initialLastDate: recordDate.lastDate,
                      firstDate: DateTime(2019),
                      lastDate: DateTime.now(),
                    ).catchError((_) {});
                    if (picked != null) {
                      if (picked.length < 2) {
                        recordDate.setDates(picked[0], picked[0]);
                      } else {
                        recordDate.setDates(picked[0], picked.last);
                      }
                    }
                  },
                  child: Text(
                    dateToNormalString(recordDate.firstDate) +
                        (recordDate.lastDate == recordDate.firstDate ||
                                recordDate.lastDate == null
                            ? ""
                            : " - " + dateToNormalString(recordDate.lastDate)),
                    style: TextStyle(fontSize: 22.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: RefreshIndicator(
          strokeWidth: 3.0,
          backgroundColor: Theme.of(context).primaryColor,
          color: Theme.of(context).backgroundColor,
          key: _refreshIndicatorKey,
          onRefresh: () {
            return _onRefresh(recordDate);
          },
          child: BlocListener<EmojisBloc, EmojisState>(
            listener: (context, state) {
              if (state is EmojisFailed) {
                Scaffold.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text("Failed to load emotions"),
                    ),
                  );
              }
            },
            child: BlocBuilder<EmojisBloc, EmojisState>(
              builder: (context, state) {
                if (state is EmojisLoadedState) {
                  recordDate.setPercentages(state.emojisModel);
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child:
                            _buildRecordList(Provider.of<RecordDate>(context)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            color: Theme.of(context).textSelectionColor,
                            child: Text("Statistics",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black)),
                            onPressed: () {
                              if (recordDate == null ||
                                  recordDate.emotionData == null ||
                                  recordDate.emotionData.isEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      backgroundColor:
                                          Theme.of(context).backgroundColor,
                                      body: Center(
                                        child: Text("No Records yet",
                                            style: TextStyle(fontSize: 25.0)),
                                      ),
                                    ),
                                  ),
                                );
                              } else
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (incontext) =>
                                        ChangeNotifierProvider.value(
                                      value: recordDate,
                                      builder: (context, _) {
                                        return AllStats();
                                      },
                                    ),
                                  ),
                                );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
                if (state is EmojisLoadingState) {
                  return LoadingIndicator();
                }
                return ListView();
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>> getFileLists() async {
    final externalPath = await getExternalStorageDirectory();
    final fileLists =
        Directory(externalPath.path + '/${await UserRepository.getUserName()}')
            .listSync()
            .map((i) => i.path.split('/').last)
            .toList();
    return fileLists;
  }

  Widget _buildRecordList(RecordDate recordDate) {
    return FutureBuilder(
      future: getFileLists(),
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          return ChangeNotifierProvider<RecordDate>.value(
            value: Provider.of<RecordDate>(context),
            builder: (context, _) {
              return RecordList(recordList: snapshot.data);
            },
          );
        }
        if (snapshot.data == null)
          return Stack(children: [
            Center(
              child: Text('No Records', style: TextStyle(fontSize: 25.0)),
            ),
            ListView(),
          ]);
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
