part of 'emojis_bloc.dart';

@immutable
abstract class EmojisState {}

class EmojisInitialState extends EmojisState {}

class EmojisLoadingState extends EmojisState {}

class EmojisLoadedState extends EmojisState {
  final List<EmojisModel> emojisModel;
  EmojisLoadedState(this.emojisModel);
}

class EmojisFailed extends EmojisState {
  final Exception e;
  EmojisFailed(this.e);
}
