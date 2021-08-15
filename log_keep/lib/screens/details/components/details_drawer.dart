import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/app/configs.dart';
import 'package:log_keep/common/utilities/web_utilities.dart';
import 'package:log_keep/common/widgets/drawer_card.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/screens/settings/settings_screen.dart';
import 'package:log_keep_shared/log_keep_shared.dart';
import 'package:proviso/proviso.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsDrawer extends StatelessWidget {
  final LogAnalysisEntity log;

  DetailsDrawer({Key key, this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    final limitedView = height <= 1024;

    return Drawer(
      child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          children: <Widget>[
            SizedBox(height: 5),
            DrawerCard(
                text: 'DOWNLOAD',
                color: Theme.of(context).cardColor,
                onTap: () {
                  WebUtilities.downloadStringAsDocument(
                      log.originalLog.data.contents);
                }),
            DrawerCard(
                text: 'COPY LINK TO LOG',
                color: Theme.of(context).cardColor,
                onTap: () {
                  Navigator.of(context).pop();
                  FlutterClipboard.copy(serverUrlFormat() + log.originalLog.info.id)
                      .then((result) {
                    final snackBar =
                        SnackBar(content: Text('Link copied to clipboard'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                }),
            DrawerCard(
                text: 'OPEN IN NEW TAB',
                color: Theme.of(context).cardColor,
                onTap: () {
                  WebUtilities.openStringContentInNewPage(
                      log.originalLog.data.contents);
                }),
            DrawerCard(
                text: 'OPEN IN DB',
                color: Theme.of(context).cardColor,
                onTap: () async {
                  var url = databaseAdminUrl() +
                      '/data~2F' +
                      logContentsCollection +
                      '~2F' +
                      log.originalLog.data.id;
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    final snackBar =
                        SnackBar(content: Text('Error opening db page'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }),
            ConditionWidget(
              condition: !limitedView,
              widget: Column(
                children: [
                  SizedBox(height: 30),
                  Icon(Icons.settings, size: 80),
                  SizedBox(height: 30),
                  Column(
                    children: [
                      drawThemeModeCard(context, Icons.sync, ThemeMode.system),
                      drawThemeModeCard(
                          context, Icons.lightbulb_outline, ThemeMode.light),
                      drawThemeModeCard(context, Icons.lightbulb, ThemeMode.dark),
                    ],
                  ),
                ],
              ),
            )
          ]),
    );
  }
}
