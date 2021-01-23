import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:log_keep/bloc/global/events_stream.dart';
import 'package:log_keep/bloc/global/global_events.dart';
import 'package:log_keep/bloc/log_infos/log_infos_event.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'log_infos_state.dart';

class LogInfosBloc extends Bloc<LogInfosEvent, LogInfosState> {
  final EventsStream eventsStream;
  final LogsRepository logsRepository;

  StreamSubscription _eventsSubscription;
  StreamSubscription _logsSubscription;

  LogInfosBloc({this.eventsStream, this.logsRepository})
      : super(LogInfosNotLoaded()) {
    _eventsSubscription?.cancel();
    _eventsSubscription = eventsStream.events().listen((event) {
      if (event is ProjectSelected) {
        add(LoadLogInfos(event.project));
      }
    });
  }

  @override
  Stream<LogInfosState> mapEventToState(LogInfosEvent event) async* {
    if (event is LoadLogInfos) {
      yield* _mapLoadLogInfosToState(event);
    } else if (event is LogInfosUpdated) {
      yield* _mapLogInfosUpdateToState(event);
    }
  }

  Stream<LogInfosState> _mapLoadLogInfosToState(LoadLogInfos event) async* {
    _logsSubscription?.cancel();
    _logsSubscription = logsRepository.getLogsForProject(event.project).listen(
          (logs) => add(LogInfosUpdated(logs)),
        );
  }

  Stream<LogInfosState> _mapLogInfosUpdateToState(
      LogInfosUpdated event) async* {
    yield LogInfosLoaded(event.logs);
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    _logsSubscription?.cancel();
    return super.close();
  }
}
