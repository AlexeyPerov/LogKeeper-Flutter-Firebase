import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:web_browser/web_browser.dart';
import 'package:universal_html/html.dart' as html;

class LogContentsView extends StatefulWidget {
  final LogAnalysisEntity log;
  final int mode;

  LogContentsView({Key key, @required this.log, @required this.mode})
      : super(key: key);

  @override
  _LogContentsViewState createState() => _LogContentsViewState();
}

class _LogContentsViewState extends State<LogContentsView> {
  var lineFoldouts = Map<int, bool>();
  var errorFoldouts = Map<int, bool>();

  @override
  Widget build(BuildContext context) {
    if (widget.mode == 1) {
      return _buildLogListView(widget.log.lines, lineFoldouts);
    } else if (widget.mode == 2) {
      return _buildLogListView(
          widget.log.lines.where((x) => x.alarm).toList(growable: false),
          errorFoldouts);
    } else {
      return _buildWebRawView();
    }
  }

  Widget _buildLogListView(List<LogLine> lines, Map<int, bool> foldouts) {
    var textStyle = TextStyle(
        height: 1.2, fontSize: 14.0, letterSpacing: 0.5, wordSpacing: 1);

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: lines.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == lines.length) {
          return SizedBox(height: 80);
        }

        var line = lines[index];
        if (line.contents.length > 300) {
          // var folded = foldouts.containsKey(index) ? [index] : false;
          return Text(line.contents.substring(0, 25) + "...", style: textStyle);
        } else {
          return Text(line.contents, style: textStyle);
        }
      },
    );
  }

  Widget _buildWebRawView() {
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
  }
}
