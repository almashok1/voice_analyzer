part of 'emojis_bloc.dart';

@immutable
abstract class EmojisEvent {
  const EmojisEvent();
}

class EmojisLoad extends EmojisEvent {
  EmojisLoad();
}
