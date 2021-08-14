import 'package:universal_html/html.dart' as html;

class WebUtilities {
  static void openStringContentInNewPage(String contentToShow) {
    final contents = createHtmlForLogContents(contentToShow);
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
      String rawContents) {
    return '<html><body><pre>' + rawContents + '</pre></body></html>';
  }
}
