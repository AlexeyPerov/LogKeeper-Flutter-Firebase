import 'package:tuple/tuple.dart';

extension StringExtension on String {
  Tuple2<String, String> splitWordsByLength(int length) {
    if (this == null) {
      return new Tuple2('', '');
    }

    var str = this;

    String part1;
    String part2;

    if (str.length < length) {
      part1 = str;
      part2 = '';
    } else {
      var regExp = new RegExp(r"((\b[^\s]+\b)((?<=\.\w).)?)");
      var matches = regExp.allMatches(str);

      var result = matches.lastWhere((x) => x.start <= length, orElse: () => null);
      if (result == null) {
        return new Tuple2(str, '');
      }

      var targetLength = result.start;
      part1 = str.substring(0, targetLength);
      part2 = str.substring(targetLength);
    }

    return new Tuple2(part1, part2);
  }
}
