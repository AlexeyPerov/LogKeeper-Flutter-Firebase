import 'package:tuple/tuple.dart';

extension StringExtension on String {
  Tuple2<String, String> splitWordsByLength(int length) {
    final str = this;

    late final String part1;
    late final String part2;

    if (str.length < length) {
      part1 = str;
      part2 = '';
    } else {
      final regExp = RegExp(r'((\b[^\s]+\b)((?<=\.\w).)?)');
      final matches = regExp.allMatches(str);
      final filtered = matches.where((x) => x.start <= length);
      if (filtered.isEmpty) {
        return Tuple2(str, '');
      }
      final result = filtered.last;
      final targetLength = result.start;
      part1 = str.substring(0, targetLength);
      part2 = str.substring(targetLength);
    }

    return Tuple2(part1, part2);
  }
}
