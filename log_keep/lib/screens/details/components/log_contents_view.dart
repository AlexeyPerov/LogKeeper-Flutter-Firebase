import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/screens/details/details_screen.dart';
import 'package:log_keep/common/widgets/condition_widget.dart';
import 'package:log_keep/common/widgets/log_html_preview.dart';

class LogContentsView extends StatefulWidget {
  final LogAnalysisEntity log;
  final int mode;
  final bool webView;

  const LogContentsView(
      {super.key,
      required this.log,
      required this.mode,
      required this.webView});

  @override
  _LogContentsViewState createState() => _LogContentsViewState();
}

class _LogContentsViewState extends State<LogContentsView> {
  final Map<int, _LineOptions> _lineParams = {};

  var _logTextStyle = const TextStyle(
      height: 1.5, fontSize: 14.0, letterSpacing: 0.75, wordSpacing: 1.1);

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

  Widget _buildLogListView({
    required List<LogLine> lines,
    required Map<int, _LineOptions> lineParams,
    required bool selectableText,
    required bool showAlarmIcons,
  }) {
    var width = MediaQuery.of(context).size.width;
    final limitedView = width <= 1024;

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: lines.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == lines.length) {
          return SizedBox(height: 80);
        }

        var line = lines[index];
        var canBeFolded = line.contents.length > 512 ||
            line.contents.split('\n').length >= 10;
        var longLine = canBeFolded;
        var alarm = line.alarm;

        final opts = lineParams[line.index];
        var selectable = opts?.selectable ?? selectableText;

        var defaultUnfoldedValue = !longLine || !canBeFolded || alarm;
        if (limitedView) {
          defaultUnfoldedValue = false;
        }
        var unfolded = opts?.unfolded ?? defaultUnfoldedValue;

        var contents = line.contents;

        if (!unfolded) {
          var firstLine = line.contents.split('\n')[0];
          contents = firstLine.length > 256
              ? line.contents.substring(0, 256) + "....."
              : (firstLine + '\n.....');
        }

        var backColor = index % 2 != 0
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.onSurface;

        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            decoration: BoxDecoration(
                color: backColor,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                    color: alarm ? Color(0xFFC19652) : Color(0xFF000000),
                    width: alarm ? 2 : 1)),
            child: Padding(
              padding: const EdgeInsets.only(top: 7, bottom: 7, left: 0),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _drawFoldWidgets(line, canBeFolded, unfolded, lineParams),
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
                  padding: const EdgeInsets.only(top: 4, left: 3),
                  child: Text(line.index.toString(), style: _logIndexTextStyle),
                ),
                ConditionWidget(
                    condition: !limitedView,
                    widget: _drawFoldWidgets(
                        line, canBeFolded, unfolded, lineParams)),
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

  Widget _drawFoldWidgets(LogLine line, bool canBeFolded, bool unfolded,
      Map<int, _LineOptions> lineParams) {
    return ConditionWidget(
        condition: canBeFolded,
        widget: ConditionWidget(
            condition: unfolded,
            widget: IconButton(
                icon: Icon(Icons.unfold_less),
                alignment: Alignment.topCenter,
                color: Colors.grey,
                padding: const EdgeInsets.only(right: 5),
                onPressed: () => setState(() {
                      lineParams[line.index] ??= _LineOptions();
                      lineParams[line.index]!.unfolded = false;
                    })),
            fallback: IconButton(
                icon: Icon(Icons.unfold_more),
                alignment: Alignment.topCenter,
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.only(right: 5),
                onPressed: () => setState(() {
                      lineParams[line.index] ??= _LineOptions();
                      lineParams[line.index]!.unfolded = true;
                    }))),
        fallback: SizedBox(width: 40));
  }

  Widget _buildWebRawView() {
    if (detailsDrawerOpened){
      // HACK because webView block Drawer ray casts. So we disable webView at that moment
      return Container();
    }

    final textColor = Theme.of(context).textTheme.bodyLarge?.color ??
        Theme.of(context).colorScheme.onSurface;
    final textRgb =
        'rgb(${(textColor.r * 255).round()}, ${(textColor.g * 255).round()}, ${(textColor.b * 255).round()})';

    final backColor = Theme.of(context).colorScheme.surface;
    final backRgb =
        'rgb(${(backColor.r * 255).round()}, ${(backColor.g * 255).round()}, ${(backColor.b * 255).round()})';

    var rawContents = widget.log.originalLog.data.contents;
    final contents = '<html><body style="background-color:$backRgb">'
            '<pre style="color:$textRgb">' +
        rawContents +
        '</pre></body></html>';

    var width = MediaQuery.of(context).size.width;
    var browserWidth = min(850, width);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(color: Colors.grey[300]),
      alignment: Alignment.center,
      child: LogHtmlPreview(
        html: contents,
        maxContentWidth: browserWidth.toDouble(),
      ),
    );
  }

  Widget _buildWebView(List<LogLine> lines) {
    if (detailsDrawerOpened){
      // HACK because webView block Drawer ray casts. So we disable webView at that moment
      return Container();
    }

    final textColor = Theme.of(context).textTheme.bodyLarge?.color ??
        Theme.of(context).colorScheme.onSurface;
    final textRgb =
        'rgb(${(textColor.r * 255).round()}, ${(textColor.g * 255).round()}, ${(textColor.b * 255).round()})';

    final backColor = Theme.of(context).colorScheme.surface;
    final backRgb =
        'rgb(${(backColor.r * 255).round()}, ${(backColor.g * 255).round()}, ${(backColor.b * 255).round()})';

    var lineContents = '';

    for (var line in lines) {
      lineContents += '<pre style="color:$textRgb">' + line.contents + '</pre>';
    }

    final contents = '<html><body style="background-color:$backRgb">' +
        lineContents +
        '</body></html>';
    var width = MediaQuery.of(context).size.width;
    var browserWidth = min(850, width);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(color: Colors.grey[300]),
      alignment: Alignment.center,
      child: LogHtmlPreview(
        html: contents,
        maxContentWidth: browserWidth.toDouble(),
      ),
    );
  }
}

class _LineOptions {
  bool unfolded = false;
  bool selectable = false;
}
