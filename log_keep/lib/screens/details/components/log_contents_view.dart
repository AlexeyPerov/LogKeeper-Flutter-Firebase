import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
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
  static const _initialLineChunk = 2500;
  static const _moreLineChunk = 6000;

  final Map<int, _LineOptions> _lineParams = {};
  final Map<int, List<LogLine>> _filteredByMode = {};

  String? _cachedWebViewHtml;
  String? _cachedWebViewPlain;
  List<LogLine>? _cachedWebViewLinesRef;
  LogAnalysisEntity? _cachedWebViewLog;
  int? _cachedWebViewMode;
  String? _cachedWebViewTextRgb;
  String? _cachedWebViewBackRgb;

  String? _cachedRawHtml;
  String? _cachedRawPlain;
  LogAnalysisEntity? _cachedRawLog;
  String? _cachedRawTextRgb;
  String? _cachedRawBackRgb;

  int _visibleLineLimit = 0;
  List<LogLine>? _linesRefForIncremental;

  var _logTextStyle = const TextStyle(
      height: 1.5, fontSize: 14.0, letterSpacing: 0.75, wordSpacing: 1.1);

  var _logIndexTextStyle = const TextStyle(
      height: 1.2,
      fontSize: 14.0,
      letterSpacing: 0.5,
      wordSpacing: 1,
      color: Colors.grey);

  @override
  void didUpdateWidget(LogContentsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.log, widget.log)) {
      _filteredByMode.clear();
      _lineParams.clear();
      _cachedWebViewHtml = null;
      _cachedWebViewLinesRef = null;
      _cachedWebViewLog = null;
      _cachedWebViewMode = null;
      _cachedWebViewTextRgb = null;
      _cachedWebViewBackRgb = null;
      _cachedRawHtml = null;
      _cachedRawPlain = null;
      _cachedRawLog = null;
      _cachedRawTextRgb = null;
      _cachedRawBackRgb = null;
      _linesRefForIncremental = null;
    }
  }

  List<LogLine> _linesForMode(int mode) {
    switch (mode) {
      case 1:
        return widget.log.lines;
      case 2:
        return _filteredByMode.putIfAbsent(
          2,
          () => widget.log.lines.where((x) => x.alarm).toList(growable: false),
        );
      case 3:
        return _filteredByMode.putIfAbsent(
          3,
          () => widget.log.lines.where((x) => x.model).toList(growable: false),
        );
      case 4:
        return _filteredByMode.putIfAbsent(
          4,
          () => widget.log.lines.where((x) => x.cheat).toList(growable: false),
        );
      case 5:
        return _filteredByMode.putIfAbsent(
          5,
          () => widget.log.lines.where((x) => x.tutorial).toList(growable: false),
        );
      default:
        return widget.log.lines;
    }
  }

  bool _showAlarmIconsForMode(int mode) {
    return mode != 2;
  }

  /// Modes 2–5 used to prefer selection on native; Web uses plain [Text] for perf.
  bool _selectableDefaultForMode(int mode) {
    if (mode == 1) {
      return false;
    }
    return !kIsWeb;
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    if (mode < 1 || mode > 5) {
      return _buildWebRawView();
    }

    final lines = _linesForMode(mode);
    if (widget.webView) {
      return _buildWebView(lines);
    }

    return _buildLogListView(
      lines: lines,
      lineParams: _lineParams,
      selectableText: _selectableDefaultForMode(mode),
      showAlarmIcons: _showAlarmIconsForMode(mode),
    );
  }

  void _resetIncrementalIfNeeded(List<LogLine> lines) {
    if (!identical(_linesRefForIncremental, lines)) {
      _linesRefForIncremental = lines;
      final total = lines.length;
      _visibleLineLimit =
          total <= _initialLineChunk ? total : _initialLineChunk;
      if (_visibleLineLimit < total) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          _expandLinesBatch();
        });
      }
    }
  }

  void _expandLinesBatch() {
    final total = _linesRefForIncremental?.length ?? 0;
    if (_visibleLineLimit >= total || total == 0) {
      return;
    }
    setState(() {
      _visibleLineLimit =
          total < _visibleLineLimit + _moreLineChunk
              ? total
              : _visibleLineLimit + _moreLineChunk;
    });
    if (_visibleLineLimit < total) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _expandLinesBatch();
        }
      });
    }
  }

  Widget _buildLogListView({
    required List<LogLine> lines,
    required Map<int, _LineOptions> lineParams,
    required bool selectableText,
    required bool showAlarmIcons,
  }) {
    _resetIncrementalIfNeeded(lines);
    var width = MediaQuery.of(context).size.width;
    final limitedView = width <= 1024;
    final displayCount =
        lines.length < _visibleLineLimit ? lines.length : _visibleLineLimit;
    final webRowStyle = kIsWeb;

    return ListView.builder(
      shrinkWrap: false,
      scrollDirection: Axis.vertical,
      itemCount: displayCount + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == displayCount) {
          return SizedBox(height: 80);
        }

        var line = lines[index];
        var canBeFolded = line.contents.length > 512 ||
            line.newlineCount >= 9;
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
          final firstSegment = line.firstNewlineIndex < 0
              ? line.contents
              : line.contents.substring(0, line.firstNewlineIndex);
          contents = firstSegment.length > 256
              ? line.contents.substring(0, 256) + "....."
              : (firstSegment + '\n.....');
        }

        final theme = Theme.of(context);
        final cardBackground = theme.cardColor;
        final alternateStripe = theme.brightness == Brightness.dark
            ? Color.lerp(cardBackground, Colors.white, 0.08)!
            : Color.lerp(cardBackground, Colors.black, 0.06)!;
        final backColor =
            index.isEven ? cardBackground : alternateStripe;

        final borderRadius =
            webRowStyle ? 8.0 : 20.0;
        final alarmBorderWidth = webRowStyle ? 1.0 : 2.0;
        final normalBorderWidth = webRowStyle ? 1.0 : 1.0;
        final normalBorderColor =
            webRowStyle ? theme.dividerColor : const Color(0xFF000000);

        if (index == displayCount - 1 && displayCount < lines.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _expandLinesBatch();
            }
          });
        }

        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            decoration: BoxDecoration(
                color: backColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                    color: alarm ? const Color(0xFFC19652) : normalBorderColor,
                    width: alarm ? alarmBorderWidth : normalBorderWidth)),
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

    final rawContents = widget.log.originalLog.data.contents;

    String contents;
    if (identical(_cachedRawLog, widget.log) &&
        _cachedRawTextRgb == textRgb &&
        _cachedRawBackRgb == backRgb &&
        _cachedRawHtml != null) {
      contents = _cachedRawHtml!;
    } else {
      final escaped = const HtmlEscape().convert(rawContents);
      contents =
          '<html><head><meta name="viewport" content="width=device-width, initial-scale=1"></head>'
          '<body style="margin:0;padding:8px;background-color:$backRgb;box-sizing:border-box;">'
          '<pre style="color:$textRgb;white-space:pre-wrap;word-break:break-word;overflow-wrap:anywhere;margin:0;width:100%;max-width:100%;box-sizing:border-box;font-family:monospace;font-size:14px;line-height:1.4;">'
          '$escaped'
          '</pre></body></html>';
      _cachedRawLog = widget.log;
      _cachedRawTextRgb = textRgb;
      _cachedRawBackRgb = backRgb;
      _cachedRawHtml = contents;
      _cachedRawPlain = rawContents;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(color: Colors.grey[300]),
      alignment: Alignment.center,
      child: LogHtmlPreview(
        html: contents,
        maxContentWidth: double.infinity,
        plainTextFallback: _cachedRawPlain ?? rawContents,
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

    final String contents;
    final String plainTextFallback;
    if (identical(_cachedWebViewLog, widget.log) &&
        _cachedWebViewMode == widget.mode &&
        identical(_cachedWebViewLinesRef, lines) &&
        _cachedWebViewTextRgb == textRgb &&
        _cachedWebViewBackRgb == backRgb &&
        _cachedWebViewHtml != null &&
        _cachedWebViewPlain != null) {
      contents = _cachedWebViewHtml!;
      plainTextFallback = _cachedWebViewPlain!;
    } else {
      final body =
          lines.map((l) => const HtmlEscape().convert(l.contents)).join('\n');
      contents =
          '<html><head><meta name="viewport" content="width=device-width, initial-scale=1"></head>'
          '<body style="margin:0;padding:8px;background-color:$backRgb;box-sizing:border-box;">'
          '<pre style="color:$textRgb;white-space:pre-wrap;word-break:break-word;overflow-wrap:anywhere;margin:0;width:100%;max-width:100%;box-sizing:border-box;font-family:monospace;font-size:14px;line-height:1.4;">'
          '$body'
          '</pre></body></html>';
      plainTextFallback = lines.map((l) => l.contents).join('\n');
      _cachedWebViewHtml = contents;
      _cachedWebViewPlain = plainTextFallback;
      _cachedWebViewLinesRef = lines;
      _cachedWebViewLog = widget.log;
      _cachedWebViewMode = widget.mode;
      _cachedWebViewTextRgb = textRgb;
      _cachedWebViewBackRgb = backRgb;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(color: Colors.grey[300]),
      alignment: Alignment.center,
      child: LogHtmlPreview(
        html: contents,
        maxContentWidth: double.infinity,
        plainTextFallback: plainTextFallback,
      ),
    );
  }
}

class _LineOptions {
  bool unfolded = false;
  bool selectable = false;
}
