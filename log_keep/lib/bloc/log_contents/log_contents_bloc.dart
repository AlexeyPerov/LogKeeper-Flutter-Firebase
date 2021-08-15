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
    var totalAlarmsCount = 0;
    var totalCheatCount = 0;
    var totalModelCount = 0;
    var totalTutorialCount = 0;

    final alarmExp = new RegExp(
        'exception|warning|incorrect|timeout|unable|cannot|fail|can\'t',
        caseSensitive: false);
    final cheatExp = new RegExp('cheat', caseSensitive: false);
    final tutorialExp = new RegExp('tutorial', caseSensitive: false);
    final modelExp = new RegExp(
        r'(\[PlayerService\])|(\[Server\])|(Request:)|(Response:)|(Received response)',
        caseSensitive: false);

    for (int i = 0; i < linesRaw.length; i++) {
      var rawLine = linesRaw[i];

      if (rawLine.endsWith('\n')) {
        rawLine = rawLine.replaceRange(rawLine.length - 1, rawLine.length, '');
      }

      final cheatCount = cheatExp.allMatches(rawLine).length;
      final tutorialCount = tutorialExp.allMatches(rawLine).length;
      final modelCount = modelExp.allMatches(rawLine).length;

      var alarmsCount = alarmExp.allMatches(rawLine).length;

      final errorMatches = rawLine.allMatches("error").length;
      final fakeErrorMatches = rawLine.allMatches('error\":null').length;
      if (errorMatches != fakeErrorMatches) {
        alarmsCount = errorMatches - fakeErrorMatches;
      }

      final isAlarm = alarmsCount > 0;
      final isCheat = cheatCount > 0;
      final isModel = modelCount > 0;
      final isTutorial = tutorialCount > 0;

      lines.add(LogLine(i, rawLine, isAlarm, isCheat, isModel, isTutorial));

      totalAlarmsCount += alarmsCount;
      totalCheatCount += cheatCount;
      totalModelCount += modelCount;
      totalTutorialCount += tutorialCount;
    }

    add(LogContentsUpdated(LogAnalysisEntity(log, lines, totalAlarmsCount,
        totalCheatCount, totalModelCount, totalTutorialCount)));
  }

  Stream<LogContentsState> _mapLogContentsUpdateToState(
      LogContentsUpdated event) async* {
    yield LogContentsLoaded(event.log);
  }
}
