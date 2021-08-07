import 'package:flutter/material.dart';
import 'package:log_keep/app/configs.dart';
import 'package:log_keep/app/theme/theme_constants.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:log_keep/common/utilities/navigator_utilities.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/screens/details/services/log_deletion_service.dart';
import 'package:log_keep/screens/home/home_screen.dart';
import 'log_contents_view.dart';

class LogView extends StatefulWidget {
  final LogAnalysisEntity log;
  final TextEditingController linkController;

  LogView({Key key, @required this.log})
      : this.linkController =
            new TextEditingController(text: serverUrlFormat() + log.originalLog.info.id),
        super(key: key);

  @override
  _LogViewState createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  int _mode = 1;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 2),
      Row(children: [
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => NavigatorUtilities.pop(context, (c) => HomeScreen()),
          icon: Icon(Icons.arrow_back_ios, size: 25),
        ),
        Expanded(
          child: TextField(
            readOnly: true,
            controller: widget.linkController,
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => {
            LogDeletionService.performDeletion(
                    context, widget.log.originalLog.project, widget.log.originalLog.info)
                .whenComplete(() => {
                      NavigatorUtilities.pushWithNoTransition(
                          context, (_, __, ___) => HomeScreen())
                    })
          },
          icon: Icon(Icons.delete, size: 25),
        )
      ]),
      SizedBox(height: 20),
      Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              dateFormatter.format(widget.log.originalLog.info.createdAt) +
                  ' ' +
                  timeFormatter.format(widget.log.originalLog.info.createdAt),
              //style: subHeaderTextStyle,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(widget.log.originalLog.info.author, /*style: subHeaderTextStyle*/),
          )
        ],
      ),
      SizedBox(height: 20),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Scrollbar(
          child: ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: 10.0,
              maxHeight: 100.0,
            ),
            child: SelectableText(widget.log.originalLog.info.title,
                toolbarOptions: commonToolbarOptions(),
                style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
      SizedBox(height: 10),
      _buildModesList(),
      SizedBox(height: 10),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          child: LogContentsView(log: widget.log, mode: _mode),
        ),
      )
    ]);
  }

  Widget _buildModesList() {
    return Row(children: [
      _modeCard("Raw", 0),
      _modeCard("List", 1),
    ],);
  }

  Widget _modeCard(String title, int index) {
    var selected = _mode == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _mode = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        height: 60.0,
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
              padding: EdgeInsets.all(5.0),
              child: Text(
                  title,
                  overflow: TextOverflow.fade,
                  maxLines: 2
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5.0, bottom: 5.0),
              child: Text(
                  ""
              ),
            ),
          ],
        ),
      ),
    );
  }
}