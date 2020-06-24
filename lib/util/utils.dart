import 'package:flutter/material.dart';
import 'package:voice_analyzer/model/record_date.dart';

bool filterDates(String dateToFilter, RecordDate recordDate) {
  List<String> splitted = dateToFilter.split('_')[0].split('-');
  int year = int.parse(splitted[0]);
  int month = int.parse(splitted[1]);
  int day = int.parse(splitted[2]);
  DateTime date = DateTime(year, month, day);

  return isBetween(date, recordDate);
}

String dateToNormalString(DateTime date) {
 return  "${placeZeroIfNeeded(date.day)}.${placeZeroIfNeeded(date.month)}.${date.year}";
}

void showErrorAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    child: AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      title: Text("Error"),
      content: Text("Failed to load data"),
    ),
  );
}

bool isBetween(DateTime date, RecordDate recordDate) {
  if (atOneDay(recordDate.firstDate, recordDate.lastDate)) {
    return atOneDay(date, recordDate.firstDate);
  } else
    return (date.isBefore(recordDate.lastDate) &&
            date.isAfter(recordDate.firstDate)) ||
        atOneDay(date, recordDate.firstDate) ||
        atOneDay(date, recordDate.lastDate);
}

bool atOneDay(DateTime date, DateTime date2) {
  return date.year == date2.year &&
      date.day == date2.day &&
      date.month == date2.month;
}

String placeZeroIfNeeded(int n) {
  if (n < 10) return "0$n";
  return n.toString();
}

String createRecordPath() {
  DateTime date = DateTime.now();
  return "${date.year}-${date.month}-${date.day}_${date.hour}-${date.minute}-${date.second}";
}

bool validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  return (!regex.hasMatch(value)) ? false : true;
}
