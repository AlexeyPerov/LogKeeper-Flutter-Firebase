import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/app/configs.dart';
import 'package:log_keep/common/utilities/web_utilities.dart';
import 'package:log_keep/common/widgets/drawer_card.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep_shared/log_keep_shared.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsDrawer extends StatelessWidget {
  final LogAnalysisEntity log;

  DetailsDrawer({Key key, this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                })
          ]),
    );
  }
}
