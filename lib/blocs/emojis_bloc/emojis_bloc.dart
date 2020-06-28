import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:voice_analyzer/api/api_connection.dart';
import 'package:voice_analyzer/model/emojis_model.dart';

part 'emojis_event.dart';
part 'emojis_state.dart';

class EmojisBloc extends Bloc<EmojisEvent, EmojisState> {
  ApiConnection _apiConnection = ApiConnection();

  @override
  EmojisState get initialState => EmojisInitialState();

  @override
  Stream<EmojisState> mapEventToState(
    EmojisEvent event,
  ) async* {
    if (event is EmojisLoad) {
      yield EmojisLoadingState();
      try {
        List<EmojisModel> emojisModel = await _apiConnection.getAllRecords();
        yield EmojisLoadedState(emojisModel);
      } catch (e) {
        yield EmojisFailed(e);
      }
    }
  }
}
