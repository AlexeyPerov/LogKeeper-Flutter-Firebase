import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/app/configs.dart';
import 'package:log_keep/app/theme/theme_constants.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:log_keep/common/utilities/navigator_utilities.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/repositories/settings_repository.dart';
import 'package:log_keep/screens/home/home_screen.dart';
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
  _LogViewState createState() =>
      _LogViewState(settings.getInt("selected_log_mode"));
}

class _LogViewState extends State<LogView> {
  int _mode;

  _LogViewState(int defaultMode) {
    _mode = defaultMode;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () =>
                NavigatorUtilities.pop(context, (c) => HomeScreen()),
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
                      _mode = 1;
                    });
                  widget.onDelete();
                },
                icon: Icon(Icons.delete, size: 25),
              ))
        ]),
      ),
      SizedBox(height: 20),
      Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
                dateFormatter.format(widget.log.originalLog.info.createdAt) +
                    ' ' +
                    timeFormatter.format(widget.log.originalLog.info.createdAt),
                style: TextStyle(fontSize: 14)),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(widget.log.originalLog.info.author,
                style: TextStyle(fontSize: 14)),
          )
        ],
      ),
      SizedBox(height: 6),
      Padding(
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
      _buildModesList(),
      Divider(),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 20,
          ),
          child: LogContentsView(log: widget.log, mode: _mode),
        ),
      )
    ]);
  }

  Widget _buildModesList() {
    return Row(
      children: [
        _modeCard(Icons.web, "Raw", 0, 0),
        _modeCard(Icons.view_headline, "Logs", 1, widget.log.lines.length),
        _modeCard(Icons.error_outline, "Alarms", 2, widget.log.alarmsCount)
      ],
    );
  }

  Widget _modeCard(
      IconData icon, String title, int index, int additionalCountInfo) {
    var selected = _mode == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _mode = index;
          widget.settings.putInt("selected_log_mode", index);
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        height: 80.0,
        width: 100.0,
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [selected ? commonBoxShadow() : slightBoxShadow()],
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
                  child: Text(additionalCountInfo != 0
                      ? additionalCountInfo.toString()
                      : ""),
                ),
                Padding(
                    padding: EdgeInsets.only(right: 15.0, bottom: 10.0),
                    child: Icon(icon, size: 20))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
