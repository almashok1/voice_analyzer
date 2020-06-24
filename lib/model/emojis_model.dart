import 'dart:convert';

class EmotionData {
  List<Pair<Timeline, String>> emotionData;

  List<Pair<Timeline, String>> get data => emotionData;

  EmotionData(this.emotionData);

  EmotionData.fromJson(Map<String, dynamic> json) {
    emotionData = [];
    print(json);
    Iterable it =  json.values;
    it.forEach((element) {
      final split = element.split(":");
      final splitT = split[0].split("-");
      Timeline t = Timeline(int.parse(splitT[0]), int.parse(splitT[1])); 
      String s = split[1];
      emotionData.add(Pair(t, s));
    });
  }

  @override
  String toString() {
    return "emotionData: $emotionData";
  }
}

class EmojisModel {
  final int id;
  final int userId;
  final EmotionData emotionData;
  final String duration;
  final String name;
  final String timestamp;

  EmojisModel(this.id, this.userId, this.emotionData, this.duration, this.name, this.timestamp);

  EmojisModel.fromJson(Map<String, dynamic> jsonParsed) 
    : id = jsonParsed['id'] as int,
      userId = jsonParsed['userId'],
      emotionData = EmotionData.fromJson(json.decode(jsonParsed['emotion_data'])),
      duration = jsonParsed['duration'],
      name = jsonParsed['name'],
      timestamp = jsonParsed['timestamp'];

  @override
  String toString() {
    return "id -> $id, emotionData -> $emotionData";
  }
}

class Pair<F, T> {
  final F f;
  final T t;

  F get first => f;
  T get last => t;
  Pair(this.f, this.t);

  @override
  String toString() {
    return 'pair: [${f.toString()}, ${t.toString()}]';
  }
}

class Timeline {
  final int first;
  final int last;

  Timeline(this.first, this.last);

  @override
  String toString() {
    return "[$first - $last]";
  }
}