import 'package:flutter/material.dart';
import 'package:log_keep/app/configs.dart';
import 'package:log_keep/app/theme/theme_constants.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:log_keep/common/utilities/navigator_utilities.dart';
import 'package:log_keep/screens/details/services/log_deletion_service.dart';
import 'package:log_keep_shared/log_keep_shared.dart';
import 'package:log_keep/screens/home/home_screen.dart';
import 'log_contents_view.dart';

class LogView extends StatefulWidget {
  final LogEntity log;
  final TextEditingController linkController;

  LogView({Key key, @required this.log})
      : this.linkController =
            new TextEditingController(text: serverUrlFormat() + log.info.id),
        super(key: key);

  @override
  _LogViewState createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  @override
  Widget build(BuildContext context) {
    var subHeaderTextStyle = TextStyle(
      color: Color(0xFFAFB4C6),
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
    );

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
                    context, widget.log.project, widget.log.info)
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
              dateFormatter.format(widget.log.info.createdAt) +
                  ' ' +
                  timeFormatter.format(widget.log.info.createdAt),
              //style: subHeaderTextStyle,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(widget.log.info.author, /*style: subHeaderTextStyle*/),
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
            child: SelectableText(widget.log.info.title,
                toolbarOptions: commonToolbarOptions(),
                style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
      SizedBox(height: 10),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          child: LogContentsView(contents: widget.log.data.contents),
        ),
      )
    ]);
  }
}