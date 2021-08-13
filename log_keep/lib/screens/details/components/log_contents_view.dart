import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:log_keep/common/utilities/web_utilities.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:proviso/proviso.dart';
import 'package:web_browser/web_browser.dart';
import 'package:universal_html/html.dart' as html;

class LogContentsView extends StatefulWidget {
  final LogAnalysisEntity log;
  final int mode;
  final bool webView;

  LogContentsView(
      {Key key,
      @required this.log,
      @required this.mode,
      @required this.webView})
      : super(key: key);

  @override
  _LogContentsViewState createState() => _LogContentsViewState();
}

class _LogContentsViewState extends State<LogContentsView> {
  var _lineParams = Map<int, _LineOptions>();

  var _logTextStyle = const TextStyle(
      height: 1.2, fontSize: 14.0, letterSpacing: 0.5, wordSpacing: 1);

  var _logIndexTextStyle = const TextStyle(
      height: 1.2,
      fontSize: 14.0,
      letterSpacing: 0.5,
      wordSpacing: 1,
      color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    if (widget.mode == 1) {
      final lines = widget.log.lines;

      if (widget.webView) {
        return _buildWebView(lines);
      }

      return _buildLogListView(
          lines: lines,
          lineParams: _lineParams,
          selectableText: false,
          showAlarmIcons: true);
    } else if (widget.mode == 2) {
      final lines =
          widget.log.lines.where((x) => x.alarm).toList(growable: false);

      if (widget.webView) {
        return _buildWebView(lines);
      }

      return _buildLogListView(
          lines: lines,
          lineParams: _lineParams,
          selectableText: true,
          showAlarmIcons: false);
    } else if (widget.mode == 3) {
      final lines =
          widget.log.lines.where((x) => x.model).toList(growable: false);

      if (widget.webView) {
        return _buildWebView(lines);
      }

      return _buildLogListView(
          lines: lines,
          lineParams: _lineParams,
          selectableText: true,
          showAlarmIcons: true);
    } else if (widget.mode == 4) {
      final lines =
          widget.log.lines.where((x) => x.cheat).toList(growable: false);

      if (widget.webView) {
        return _buildWebView(lines);
      }

      return _buildLogListView(
          lines: lines,
          lineParams: _lineParams,
          selectableText: true,
          showAlarmIcons: true);
    } else if (widget.mode == 5) {
      final lines =
          widget.log.lines.where((x) => x.tutorial).toList(growable: false);

      if (widget.webView) {
        return _buildWebView(lines);
      }

      return _buildLogListView(
          lines:
              widget.log.lines.where((x) => x.tutorial).toList(growable: false),
          lineParams: _lineParams,
          selectableText: true,
          showAlarmIcons: true);
    } else {
      return _buildWebRawView();
    }
  }

  Widget _buildLogListView(
      {List<LogLine> lines,
      Map<int, _LineOptions> lineParams,
      bool selectableText,
      bool showAlarmIcons}) {
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
        var longLine = canBeFolded && line.contents.length > 256;
        var alarm = line.alarm;

        var selectable = lineParams[line.index] != null
            ? lineParams[line.index].selectable
            : selectableText;

        var defaultUnfoldedValue = !longLine || !canBeFolded;
        var unfolded = lineParams[line.index] != null
            ? lineParams[line.index].unfolded
            : defaultUnfoldedValue;

        var contents = line.contents;

        if (!unfolded) {
          var firstLine = line.contents.split('\n')[0];
          contents = firstLine.length > 128
              ? line.contents.substring(0, 128) + "..."
              : firstLine;
        }

        var backColor = index % 2 != 0
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.onBackground;

        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            decoration: BoxDecoration(
                color: backColor,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                    color: alarm ? Colors.orangeAccent : Color(0xFF000000),
                    width: alarm ? 2 : 0)),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ConditionWidget(
                    condition: selectable,
                    widget: Expanded(
                        child: SelectableText(contents,
                            style: _logTextStyle,
                            toolbarOptions: commonToolbarOptions())),
                    fallback:
                        Expanded(child: Text(contents, style: _logTextStyle))),
                ConditionWidget(
                    condition: showAlarmIcons && alarm,
                    widget: Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: Icon(Icons.error_outline),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 3),
                  child: Text(line.index.toString(), style: _logIndexTextStyle),
                ),
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
                                  if (lineParams[line.index] == null) {
                                    lineParams[line.index] = _LineOptions();
                                  }
                                  lineParams[line.index].unfolded = false;
                                })),
                        fallback: IconButton(
                            icon: Icon(Icons.unfold_more),
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.only(right: 5),
                            onPressed: () => setState(() {
                                  if (lineParams[line.index] == null) {
                                    lineParams[line.index] = _LineOptions();
                                  }
                                  lineParams[line.index].unfolded = true;
                                })))),
                IconButton(
                    icon: Icon(Icons.copy),
                    color: Colors.grey,
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(right: 5),
                    onPressed: () =>
                        FlutterClipboard.copy(line.contents).then((result) {
                          final snackBar = SnackBar(
                              content: Text('Log copied to clipboard'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }))
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebRawView() {
    var rawContents = widget.log.originalLog.data.contents;
    final contents = WebUtilities.createHtmlForLogContents(rawContents);
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

  Widget _buildWebView(List<LogLine> lines) {
    var lineContents = '';

    for (var line in lines) {
      lineContents += '<pre>' + line.contents + '</pre>';
    }

    final contents = '<html><body>' + lineContents + '</body></html>';
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

class _LineOptions {
  bool unfolded = false;
  bool selectable = false;
}
