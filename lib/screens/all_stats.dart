import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:voice_analyzer/api/api_connection.dart';
import 'package:voice_analyzer/model/emojis_model.dart';
import 'package:voice_analyzer/model/record_date.dart';
import 'package:voice_analyzer/util/utils.dart';

class AllStats extends StatefulWidget {
  @override
  _AllStatsState createState() => _AllStatsState();
}

class _AllStatsState extends State<AllStats>
    with SingleTickerProviderStateMixin {
  final ApiConnection _apiConnection = ApiConnection();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  Future<void> _onRefresh(RecordDate recordDate) async {
    try {
      recordDate.emotionData = await _apiConnection.getAllRecords();
      recordDate.setPercentages();
      setState(() {});
    } catch (e) {
      showErrorAlertDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordDate>(
      builder: (context, recordDate, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            title: Text("Статистика"),
            bottom: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                  child: atOneDay(recordDate.firstDate, recordDate.lastDate)
                      ? Text(
                          dateToNormalString(recordDate.firstDate),
                          style: TextStyle(fontSize: 18.0),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                      child: Center(child: Text("С"))),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Center(
                                    child: Text(dateToNormalString(
                                        recordDate.firstDate)),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                      child: Center(child: Text("ДО"))),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Center(
                                    child: Text(dateToNormalString(
                                        recordDate.lastDate)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                Tab(
                  child: Text(
                    "За все время",
                    style: TextStyle(fontSize: 18.0),
                  ),
                )
              ],
            ),
          ),
          body: RefreshIndicator(
            // key: widget.refreshIndicatorKey,
            onRefresh: () {
              return _onRefresh(recordDate);
            },
            child: Stack(
              children: [
                ListView(),
                TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _stats(recordDate),
                    _statsAll(recordDate),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final Map<String, Color> map = {
    "anger": Colors.redAccent,
    "scared": Colors.purple,
    "happy": Colors.blue,
    "sadness": Colors.pink,
    "neutral": Colors.grey,
    "disgust": Colors.lime,
    "surprised": Colors.green,
  };

  Widget _stats(RecordDate recordDate) {
    Map<String, double> percentages = {};
    recordDate.percentages.keys.forEach((key) {
      percentages.putIfAbsent(key, () => 0);
    });
    List<EmojisModel> list = []..addAll(recordDate.emotionData
        .where((i) => recordDate.filteredRecordList.contains(i.name)));
    String mostEmoji = "";
    double count = 0;
    for (var i in list) {
      for (var em in i.emotionData.data) {
        percentages[em.last] += em.first.last - em.first.first;
        if (count < percentages[em.last]) {
          count = percentages[em.last];
          mostEmoji = em.last;
        }
      }
    }
    return _buildStats(percentages, mostEmoji);
  }

  Widget _buildStats(Map<String, double> percentages, String mostEmoji) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: mostEmoji == "" ? Colors.grey : map[mostEmoji],
              boxShadow: [
                BoxShadow(
                    blurRadius: 10.0,
                    color: mostEmoji == "" ? Colors.grey : map[mostEmoji]),
              ],
            ),
            child: Center(
              child: Text(
                  mostEmoji == ""
                      ? "Нет записей"
                      : "Вы в основном " +
                          (mostEmoji == 'disgust'
                              ? 'чувствуете ${emotionTranslate[mostEmoji]}'
                              : emotionTranslate[mostEmoji]),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24.0,
                      color: mostEmoji == ""
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textSelectionColor)),
            ),
          ),
        ),
        Expanded(flex: 9, child: _buildPieChart(percentages)),
      ],
    );
  }

  Widget _statsAll(RecordDate recordDate) {
    String mostEmoji = _mostEmotion(recordDate.percentages);
    return _buildStats(recordDate.percentages, mostEmoji);
  }

  String _mostEmotion(Map<String, double> percentages) {
    double count = 0;
    String most = "";
    percentages.forEach((key, value) {
      if (value >= count) {
        most = key;
        count = value;
      }
    });
    return most;
  }

  Widget _buildPieChart(Map<String, double> percentages) {
    Map<String, double> translated = {};
    percentages.forEach((key, value) {
      translated.putIfAbsent(emotionTranslate[key], () => value);
    });
    return PieChart(
      dataMap: translated,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32.0,
      chartRadius: MediaQuery.of(context).size.width / 2.0,
      showChartValues: true,
      showChartValuesOutside: false,
      chartValueBackgroundColor: Colors.grey[200],
      colorList: [
        Colors.redAccent,
        Colors.purple,
        Colors.blue,
        Colors.pink,
        Colors.grey,
        Colors.lime,
        Colors.green,
      ],
      showLegends: true,
      legendPosition: LegendPosition.right,
      decimalPlaces: 1,
      showChartValueLabel: true,
      initialAngle: 0,
      chartValueStyle: defaultChartValueStyle.copyWith(
        color: Colors.blueGrey[900].withOpacity(0.9),
      ),
      chartType: ChartType.disc,
    );
  }
}
