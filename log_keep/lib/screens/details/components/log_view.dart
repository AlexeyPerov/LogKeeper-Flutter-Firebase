import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/app/configs.dart';
import 'package:log_keep/app/theme/theme_constants.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:log_keep/common/utilities/web_utilities.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/repositories/settings_repository.dart';
import 'package:log_keep/screens/home/home_screen.dart';
import 'package:proviso/proviso.dart';
import 'log_contents_view.dart';

class LogView extends StatefulWidget {
  final LogAnalysisEntity log;
  final TextEditingController linkController;
  final Function onDelete;
  final SettingsRepository settings;

  LogView(
      {Key key,
      @required this.log,
      @required this.onDelete,
      @required this.settings})
      : this.linkController = new TextEditingController(
            text: serverUrlFormat() + log.originalLog.info.id),
        super(key: key);

  @override
  _LogViewState createState() => _LogViewState(
      settings.getInt("selected_log_mode"),
      settings.getBool("selected_web_view_mode"));
}

class _LogViewState extends State<LogView> {
  int _mode;
  bool _useWebView;

  _LogViewState(int defaultMode, bool defaultUseWebView) {
    _mode = defaultMode;
    _useWebView = defaultUseWebView;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    final limitedView = width <= 1024 || height <= 1024;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: ConditionWidget(
          condition: !limitedView,
          widget: Row(children: [
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => HomeScreenNavigation.navigate(context),
              icon: Icon(Icons.arrow_back_ios, size: 25),
            ),
            Expanded(
              child: TextField(
                readOnly: true,
                controller: widget.linkController,
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    FlutterClipboard.copy(widget.linkController.text)
                        .then((result) {
                      final snackBar =
                          SnackBar(content: Text('Link copied to clipboard'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });
                  },
                  icon: Icon(Icons.copy, size: 25),
                )),
            Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (_mode == 0)
                      setState(() {
                        // we need this because webView block all ray casts on top of it
                        _useWebView = false;
                        widget.settings
                            .putBool("selected_web_view_mode", false);
                      });
                    widget.onDelete();
                  },
                  icon: Icon(Icons.delete, size: 25),
                ))
          ]),
        ),
      ),
      SizedBox(height: limitedView ? 6 : 20),
      ConditionWidget(
        condition: !limitedView,
        widget: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                  dateFormatter.format(widget.log.originalLog.info.createdAt) +
                      ' ' +
                      timeFormatter
                          .format(widget.log.originalLog.info.createdAt),
                  style: TextStyle(fontSize: 14)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(widget.log.originalLog.info.author,
                  style: TextStyle(fontSize: 14)),
            )
          ],
        ),
      ),
      SizedBox(height: limitedView ? 0 : 6),
      ConditionWidget(
        condition: !limitedView,
        widget: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Scrollbar(
            child: ConstrainedBox(
              constraints: new BoxConstraints(
                minHeight: 10.0,
                maxHeight: 100.0,
              ),
              child: SelectableText(widget.log.originalLog.info.title,
                  toolbarOptions: commonToolbarOptions(),
                  style: TextStyle(fontSize: 14)),
            ),
          ),
        ),
      ),
      _buildModesList(limitedView),
      Divider(),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 20,
          ),
          child: LogContentsView(
              log: widget.log, mode: _mode, webView: _useWebView),
        ),
      )
    ]);
  }

  Widget _buildModesList(bool limitedView) {
    var width = MediaQuery.of(context).size.width;
    final limitedView = width <= 1024;

    return Row(
      children: [
        ConditionWidget(
          condition: limitedView,
          widget: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => HomeScreenNavigation.navigate(context),
            icon: Icon(Icons.arrow_back_ios, size: 25),
          ),
        ),
        ConditionWidget(condition: !limitedView, widget: Spacer()),
        _modeCard(Icons.web, "Raw", 0, 0, false),
        ConditionWidget(
            condition: widget.log.alarmsCount > 0,
            widget: _modeCard(Icons.error_outline, "Alarms", 2,
                widget.log.alarmsCount, true)),
        ConditionWidget(
            condition: widget.log.lines.length > 0,
            widget: _modeCard(
                Icons.view_headline, "Logs", 1, widget.log.lines.length, true)),
        ConditionWidget(
            condition: !limitedView && widget.log.modelCount > 0,
            widget: _modeCard(
                Icons.view_headline, "Server", 3, widget.log.modelCount, true)),
        ConditionWidget(
            condition: !limitedView && widget.log.cheatCount > 0,
            widget: _modeCard(
                Icons.view_headline, "Cheat", 4, widget.log.cheatCount, true)),
        ConditionWidget(
            condition: !limitedView && widget.log.tutorialCount > 0,
            widget: _modeCard(Icons.view_headline, "Tutorial", 5,
                widget.log.tutorialCount, true)),
        SizedBox(width: limitedView ? 3 : 5),
        ConditionWidget(
          condition: width > 700,
          widget: _card(Icons.open_in_new_rounded, "New tab", () {
            WebUtilities.openStringContentInNewPage(
                widget.log.originalLog.data.contents);
          }),
        ),
        SizedBox(width: limitedView ? 3 : 25),
        ConditionWidget(condition: !limitedView, widget: Spacer()),
        IgnorePointer(
          ignoring: _mode == 0,
          child: Column(
            children: [
              IconButton(
                  iconSize: 35,
                  icon: Icon(Icons.request_page_outlined),
                  color: _useWebView || _mode == 0
                      ? Theme.of(context).colorScheme.primaryVariant
                      : Colors.grey,
                  onPressed: () {
                    setState(() {
                      _useWebView = true;
                      widget.settings.putBool("selected_web_view_mode", true);
                    });
                  }),
              Text("Web", style: TextStyle(fontSize: 10))
            ],
          ),
        ),
        ConditionWidget(
          condition: _mode != 0,
          widget: Column(
            children: [
              IconButton(
                  iconSize: 35,
                  icon: Icon(Icons.view_list),
                  color: !_useWebView
                      ? Theme.of(context).colorScheme.primaryVariant
                      : Colors.grey,
                  onPressed: () {
                    setState(() {
                      _useWebView = false;
                      widget.settings.putBool("selected_web_view_mode", false);
                    });
                  }),
              Text("Flutter", style: TextStyle(fontSize: 10))
            ],
          ),
          fallback: SizedBox(width: 51),
        )
      ],
    );
  }

  Widget _modeCard(IconData icon, String title, int index,
      int additionalCountInfo, bool canUseWebView) {
    var width = MediaQuery.of(context).size.width;
    final limitedView = width <= 1024;

    var selected = _mode == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _mode = index;
          widget.settings.putInt("selected_log_mode", index);
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: limitedView ? 3 : 10, horizontal: limitedView ? 3 : 10),
        height: 80.0,
        width: 100.0,
        decoration: BoxDecoration(
          border: Border.all(
              color: selected
                  ? Color(0xFFC19652)
                  : Theme.of(context).colorScheme.background,
              width: selected ? 0.5 : 0.5),
          color: selected
              ? Theme.of(context).colorScheme.secondaryVariant
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [selected ? heavyBoxShadow() : slightBoxShadow()],
        ),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                child: Text(title, overflow: TextOverflow.fade, maxLines: 1),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, bottom: 10.0),
                    child: Text(additionalCountInfo != 0
                        ? additionalCountInfo.toString()
                        : ""),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 15.0, bottom: 10.0),
                    child: Icon(icon),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(IconData icon, String title, Function onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        height: 80.0,
        width: 100.0,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [slightBoxShadow()],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(title, overflow: TextOverflow.fade, maxLines: 2),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 15.0, bottom: 10.0),
                    child: Icon(icon, size: 20))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
