import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:web_browser/web_browser.dart';
import 'package:universal_html/html.dart' as html;

class LogContentsView extends StatefulWidget {
  final LogAnalysisEntity log;

  LogContentsView({Key key, @required this.log}) : super(key: key) ;

  @override
  _LogContentsViewState createState() => _LogContentsViewState();
}

class _LogContentsViewState extends State<LogContentsView> {
  int _mode = 2;

  @override
  Widget build(BuildContext context) {
    if (_mode == 0) {
      final contents =
          '<html><body><pre>${widget.log.originalLog.data.contents}</pre></body></html>';
      final blob = html.Blob([contents], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);
      var width = MediaQuery.of(context).size.width;
      var browserWidth = min(850, width);
      return Container(
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(color: Colors.grey[300]),
        child: WebBrowser(
            initialUrl: url,
            iframeSettings: WebBrowserIFrameSettings(
                width: '"' + browserWidth.toString() + '"'),
            interactionSettings:
                WebBrowserInteractionSettings(topBar: null, bottomBar: null)),
      );
    } else {
      var textStyle = TextStyle(
          height: 1,
          fontSize: 14.0,
          letterSpacing: 0.5,
          wordSpacing: 1);

      return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: widget.log.lines.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == widget.log.lines.length) {
            return SizedBox(height: 80);
          }

          var line = widget.log.lines[index];
          if (line.contents.length > 300) {
            return Text("LONG LINE", style: textStyle);
          } else {
            return Text(line.contents, style: textStyle);
          }
        },
      );
    }
  }
}
