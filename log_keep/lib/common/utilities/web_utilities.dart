import 'package:log_keep/app/app.dart';
import 'package:universal_html/html.dart' as html;

class WebUtilities {
  static void openStringContentInNewPage(String contentToShow) {
    final contents = createHtmlForLogContents(contentToShow, false);
    final blob = html.Blob([contents], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, 'log');
    html.Url.revokeObjectUrl(url);
  }

  static void downloadStringAsDocument(String contentToDownload) {
    final blob = html.Blob([contentToDownload], 'application/txt');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'log.txt';
    html.document.body.children.add(anchor);
    anchor.click();
    html.document.body.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  static String createHtmlForLogContents(
      String rawContents, bool highlightKeywords) {
    var contents = rawContents;

    if (highlightKeywords) {
      var list = [
        "Exception",
        "Fail",
        "Fatal",
        "Error",
        "Warning",
        "incorrect",
        "timeout",
        "unable",
        "cannot",
        "can\'t"
      ];

      for (var keyword in list) {
        final toReplace =
            "<a href=\"#\" style=\"color:red;\">${keyword.toUpperCase()}</a>";

        final regExp = RegExp(keyword, caseSensitive: false);

        var startIndex = 0;
        var iteration = 0;

        while (iteration < 100) {
          iteration++;

          final matches = regExp.allMatches(contents, startIndex);

          if (matches.isEmpty) {
            break;
          }

          final match = matches.first;

          if (contents.substring(match.start, match.end).toLowerCase() == keyword.toLowerCase())
            contents = contents.replaceRange(match.start, match.end, toReplace);

          startIndex = match.start + toReplace.length;

          if (startIndex >= contents.length) {
            break;
          }
        }

        if (iteration >= 100) {
          logger.e('Has gone above the iteration limit for ' +
              keyword +
              ' replacement');
        }

        /*
        // This should work but it doesn't.
        // It corrupts string sometimes y replacing with an offset.
        contents = contents.replaceAllMapped(RegExp(keyword, caseSensitive: false),
                (match) => "<a href=\"#\" style=\"color:red;\">${match[0]}</a>");*/
      }
    }

    return '<html><body><pre>' + contents + '</pre></body></html>';
  }
}
