import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:proviso/proviso.dart';
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
  var _lineFoldouts = Map<int, bool>();
  var _errorFoldouts = Map<int, bool>();

  @override
  Widget build(BuildContext context) {
    if (widget.mode == 1) {
      return _buildLogListView(widget.log.lines, _lineFoldouts);
    } else if (widget.mode == 2) {
      return _buildLogListView(
          widget.log.lines.where((x) => x.alarm).toList(growable: false),
          _errorFoldouts);
    } else {
      return _buildWebRawView();
    }
  }

  Widget _buildLogListView(List<LogLine> lines, Map<int, bool> foldouts) {
    var textStyle = const TextStyle(
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
        var canBeFolded = line.contents.length > 100;
        var longLine = canBeFolded && line.contents.length > 300;
        var alarm = line.alarm;
        var defaultUnfoldedValue = !longLine || alarm || !canBeFolded;
        var unfolded = foldouts.containsKey(index)
            ? foldouts[index]
            : defaultUnfoldedValue;

        var contents =
            unfolded ? line.contents : (line.contents.substring(0, 25) + "...");

        var backColor = index % 2 != 0 ? Colors.white : Color(0xFFE6EBEB);

        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            decoration: BoxDecoration(
                color: backColor, borderRadius: BorderRadius.circular(20.0)),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(contents, style: textStyle)),
                ConditionWidget(condition: alarm, widget: Icon(Icons.whatshot)),
                ConditionWidget(
                    condition: canBeFolded,
                    widget: ConditionWidget(
                        condition: unfolded,
                        widget: IconButton(
                            icon: Icon(Icons.unfold_less),
                            alignment: Alignment.topCenter,
                            color: Colors.grey,
                            padding: const EdgeInsets.only(right: 5),
                            onPressed: () => setState(() {
                                  foldouts[index] = false;
                                })),
                        fallback: IconButton(
                            icon: Icon(Icons.unfold_more),
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.only(right: 5),
                            onPressed: () => setState(() {
                                  foldouts[index] = true;
                                })))),
                /*IconButton(
                    icon: Icon(Icons.copy),
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(right: 5),
                    onPressed: () => setState(() {
                      foldouts[index] = true;
                    }))*/
              ]),
            ),
          ),
        );
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
