import 'package:log_keep/repositories/logs_repository.dart';

/// Result of parsing raw log text in a background isolate ([compute]).
class LogParseResult {
  LogParseResult({
    required this.lines,
    required this.alarmsCount,
    required this.cheatCount,
    required this.modelCount,
    required this.tutorialCount,
  });

  final List<LogLine> lines;
  final int alarmsCount;
  final int cheatCount;
  final int modelCount;
  final int tutorialCount;
}

/// Parse log contents and classify lines. Intended for [compute] — only [String] in,
/// plain data out.
LogParseResult parseLogContentsIsolate(String contents) {
  final linesRaw = contents.split(RegExp(r'\|[0-9]+\|'));
  final lines = <LogLine>[];
  var totalAlarmsCount = 0;
  var totalCheatCount = 0;
  var totalModelCount = 0;
  var totalTutorialCount = 0;

  final alarmExp = RegExp(
      'exception|warning|incorrect|timeout|unable|cannot|fail|can\'t',
      caseSensitive: false);
  final cheatExp = RegExp('cheat', caseSensitive: false);
  final tutorialExp = RegExp('tutorial', caseSensitive: false);
  final modelExp = RegExp(
      r'(\[PlayerService\])|(\[Server\])|(Request:)|(Response:)|(Received response)',
      caseSensitive: false);

  for (var i = 0; i < linesRaw.length; i++) {
    var rawLine = linesRaw[i];

    if (rawLine.endsWith('\n')) {
      rawLine = rawLine.replaceRange(rawLine.length - 1, rawLine.length, '');
    }

    final cheatCount = cheatExp.allMatches(rawLine).length;
    final tutorialCount = tutorialExp.allMatches(rawLine).length;
    final modelCount = modelExp.allMatches(rawLine).length;

    var alarmsCount = alarmExp.allMatches(rawLine).length;

    final errorMatches = rawLine.allMatches('error').length;
    final fakeErrorMatches = rawLine.allMatches('error\":null').length;
    if (errorMatches != fakeErrorMatches) {
      alarmsCount = errorMatches - fakeErrorMatches;
    }

    var newlineCount = 0;
    var firstNewlineIndex = -1;
    for (var j = 0; j < rawLine.length; j++) {
      if (rawLine.codeUnitAt(j) == 0x0a) {
        newlineCount++;
        if (firstNewlineIndex < 0) {
          firstNewlineIndex = j;
        }
      }
    }

    lines.add(LogLine(
      i,
      rawLine,
      alarmsCount > 0,
      cheatCount > 0,
      modelCount > 0,
      tutorialCount > 0,
      newlineCount,
      firstNewlineIndex,
    ));

    totalAlarmsCount += alarmsCount;
    totalCheatCount += cheatCount;
    totalModelCount += modelCount;
    totalTutorialCount += tutorialCount;
  }

  return LogParseResult(
    lines: lines,
    alarmsCount: totalAlarmsCount,
    cheatCount: totalCheatCount,
    modelCount: totalModelCount,
    tutorialCount: totalTutorialCount,
  );
}
