import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:log_keep/bloc/log_contents/log_contents.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'log_contents_state.dart';

class LogContentsBloc extends Bloc<LogContentsEvent, LogContentsState> {
  final LogsRepository logsRepository;

  LogContentsBloc({this.logsRepository}) : super(LogContentsNotLoaded());

  @override
  Stream<LogContentsState> mapEventToState(LogContentsEvent event) async* {
    if (event is LoadLogContents) {
      yield* _mapLoadLogContentsToState(event);
    } else if (event is LogContentsUpdated) {
      yield* _mapLogContentsUpdateToState(event);
    }
  }

  Stream<LogContentsState> _mapLoadLogContentsToState(
      LoadLogContents event) async* {
    var log = await logsRepository.getLogById(event.id);

    var linesRaw = log.data.contents.split(RegExp(r"\|[0-9]+\|"));
    var lines = List<LogLine>.empty(growable: true);

    for(var rawLine in linesRaw) {
      lines.add(LogLine(rawLine, rawLine.contains("Exception")));
    }

    add(LogContentsUpdated(LogAnalysisEntity(log, lines)));
  }

  Stream<LogContentsState> _mapLogContentsUpdateToState(
      LogContentsUpdated event) async* {
    yield LogContentsLoaded(event.log);
  }
}
