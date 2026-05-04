import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:log_keep/bloc/global/events_stream.dart';
import 'package:log_keep/bloc/global/global_events.dart';
import 'package:log_keep/bloc/log_infos/log_infos_event.dart';
import 'package:log_keep/repositories/logs_repository.dart';

import 'log_infos_state.dart';

class LogInfosBloc extends Bloc<LogInfosEvent, LogInfosState> {
  LogInfosBloc({
    required this.eventsStream,
    required this.logsRepository,
  }) : super(LogInfosNotLoaded()) {
    on<LoadLogInfos>(_onLoadLogInfos);
    on<LogInfosUpdated>(_onLogInfosUpdated);

    _eventsSubscription = eventsStream.events().listen((event) {
      if (event is ProjectSelected) {
        add(LoadLogInfos(event.project));
      }
    });
  }

  final EventsStream eventsStream;
  final LogsRepository logsRepository;

  StreamSubscription<dynamic>? _eventsSubscription;
  StreamSubscription<dynamic>? _logsSubscription;

  Future<void> _onLoadLogInfos(
    LoadLogInfos event,
    Emitter<LogInfosState> emit,
  ) async {
    await _logsSubscription?.cancel();
    _logsSubscription =
        logsRepository.getLogsForProject(event.project).listen((logs) {
      add(LogInfosUpdated(logs));
    });
  }

  void _onLogInfosUpdated(
    LogInfosUpdated event,
    Emitter<LogInfosState> emit,
  ) {
    emit(LogInfosLoaded(event.logs));
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    _logsSubscription?.cancel();
    return super.close();
  }
}
