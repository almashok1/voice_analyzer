import 'package:flutter/cupertino.dart';
import 'package:voice_analyzer/model/emojis_model.dart';

class RecordDate extends ChangeNotifier {
  List<EmojisModel> _emotionData = [];
  final Map<String, double> _percentages = {
    "anger": 0,
    "scared": 0,
    "happy": 0,
    "sadness": 0,
    "neutral": 0,
    "disgust": 0,
    "surprised": 0,
  };
  List<String> filteredRecordList = [];
  DateTime _firstDate = DateTime.now();
  DateTime _lastDate;


  GlobalKey one = GlobalKey();
  GlobalKey two = GlobalKey();
  GlobalKey three = GlobalKey();
  GlobalKey four = GlobalKey();
  GlobalKey five = GlobalKey();
  GlobalKey six = GlobalKey();
  GlobalKey seven = GlobalKey();
  GlobalKey eight = GlobalKey();

  set emotionData(List<EmojisModel> list) {
    _emotionData = list;
  }

  Map<String, double> get percentages => _percentages;

  void setPercentages([List<EmojisModel> list]) {
    _percentages.keys.forEach((key) {
      _percentages[key] = 0;
    });
    if (_emotionData.isEmpty && list != null) _emotionData = list;
    for (var i in _emotionData) {
      for (var em in i.emotionData.data) {
        _percentages[em.last] += em.first.last - em.first.first;
      }
    }
  }

  List<EmojisModel> get emotionData => _emotionData;

  RecordDate() {
    _firstDate = DateTime(_firstDate.year, _firstDate.month, _firstDate.day)
      ..add(Duration(days: 1))
      ..subtract(Duration(microseconds: 1));
    _lastDate = _firstDate;
  }

  void setDates(DateTime firstDate, DateTime lastDate) {
    _firstDate = firstDate;
    _lastDate = lastDate;
    notifyListeners();
  }

  DateTime get firstDate => _firstDate;

  DateTime get lastDate => _lastDate;
}
