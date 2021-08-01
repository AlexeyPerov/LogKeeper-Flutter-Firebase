import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:web_browser/web_browser.dart';
import 'package:universal_html/html.dart' as html;

class LogContentsView extends StatefulWidget {
  final String contents;
  List<String> lines;
  List<String> logs;

  LogContentsView({Key key, @required this.contents}) : super(key: key) {
    var ls = new LineSplitter();
    lines = ls.convert(contents);

    logs = contents.split(RegExp(r"\|[0-9]+\|"));
  }

  @override
  _LogContentsViewState createState() => _LogContentsViewState();
}

class _LogContentsViewState extends State<LogContentsView> {
  int _mode = 2;

  @override
  Widget build(BuildContext context) {
    if (_mode == 0) {
      final contents =
          '<html><body><pre>${widget.contents}</pre></body></html>';
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
    } else if (_mode == 1) {
      var textStyle = TextStyle(
          height: 2,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          wordSpacing: 1);

      return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: widget.lines.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == widget.lines.length) {
            return SizedBox(height: 80);
          }

          var log = widget.lines[index];
          return Text(log, style: textStyle);
        },
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
        itemCount: widget.logs.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == widget.logs.length) {
            return SizedBox(height: 80);
          }

          var log = widget.logs[index];
          if (log.length > 300) {
            return Text("LONG LINE", style: textStyle);
          } else {
            return Text(log, style: textStyle);
          }
        },
      );
    }
  }
}
