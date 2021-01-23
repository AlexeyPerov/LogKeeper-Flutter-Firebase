import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:web_browser/web_browser.dart';
import 'package:universal_html/html.dart' as html;

class LogContentsView extends StatefulWidget {
  final String contents;

  LogContentsView({Key key, @required this.contents}) : super(key: key);

  @override
  _LogContentsViewState createState() => _LogContentsViewState();
}

class _LogContentsViewState extends State<LogContentsView> {
  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      color: Colors.black87,
      height: 1.6,
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
    );

    if (kIsWeb && widget.contents.length > 1024) {
      final contents =
          '<html><body><pre>${widget.contents}</pre></body></html>';
      final blob = html.Blob([contents], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);
      var width = MediaQuery.of(context).size.width;
      var browserWidth = min(850, width);
      return Container(
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.grey[300]
        ),
        child: WebBrowser(
            initialUrl: url,
            iframeSettings: WebBrowserIFrameSettings(width: '"' + browserWidth.toString() + '"'),
            interactionSettings:
                WebBrowserInteractionSettings(topBar: null, bottomBar: null)),
      );
    } else {
      return Scrollbar(
          child: SelectableText(widget.contents,
              toolbarOptions: commonToolbarOptions(), style: textStyle));
    }
  }
}
