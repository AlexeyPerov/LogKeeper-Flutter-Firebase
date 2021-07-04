import 'dart:ui';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/app/configs.dart';
import 'package:log_keep/common/utilities/web_utilities.dart';
import 'package:log_keep/common/widgets/drawer_card.dart';
import 'package:log_keep_shared/log_keep_shared.dart';
import 'package:proviso/proviso.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsDrawer extends StatelessWidget {
  final LogEntity log;

  DetailsDrawer({Key key, this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          children: <Widget>[
            SizedBox(height: 5),
            DrawerCard(
                text: 'OPEN IN NEW HTML PAGE',
                color: Color(0xFFF5F7FB),
                onTap: () {
                  WebUtilities.openStringContentInNewPage(log.data.contents);
                }),
            DrawerCard(
                text: 'DOWNLOAD',
                color: Color(0xFFF5F7FB),
                onTap: () {
                  WebUtilities.downloadStringAsDocument(log.data.contents);
                }),
            ConditionWidget(
              condition: !kIsWeb,
              widget: DrawerCard(
                  text: 'COPY LINK',
                  color: Color(0xFFF5F7FB),
                  onTap: () {
                    _copyLinkPressed(context);
                  }),
            ),
            DrawerCard(
                text: 'OPEN IN DB',
                color: Colors.orange[100],
                onTap: () async {
                  var url = databaseAdminUrl() +
                      '/data~2F' +
                      logContentsCollection +
                      '~2F' +
                      log.data.id;
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    final snackBar =
                        SnackBar(content: Text('Error opening db page'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
              child: Text('ID:' + log.info.id,
                  style: TextStyle(
                    color: Color(0xFFAFB4C6),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  )),
            )
          ]),
    );
  }

  void _copyLinkPressed(BuildContext context) {
    ClipboardManager.copyToClipBoard(serverUrlFormat() + log.info.id)
        .then((result) {
      final snackBar = SnackBar(content: Text('Copied to Clipboard'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }
}
