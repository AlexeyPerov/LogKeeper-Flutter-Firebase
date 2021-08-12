import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:log_keep/app/configs.dart';
import 'package:log_keep/common/widgets/drawer_card.dart';
import 'package:log_keep/screens/add_log/add_log_screen.dart';
import 'package:log_keep/screens/add_log/components/add_log_form.dart';
import 'package:log_keep/screens/error/error_screen.dart';
import 'package:log_keep/screens/settings/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          children: <Widget>[
            SizedBox(height: 5),
            DrawerCard(
                text: 'UPLOAD LOG',
                color: Colors.orange[100],
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => AddLogScreen(
                              logForm: new AddLogFormParameters())));
                }),
            DrawerCard(
                text: 'REMOTE ADMIN PANEL',
                color: Color(0xFFF5F7FB),
                onTap: () async {
                  var url = databaseAdminUrl();
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => ErrorScreen()));
                  }
                }),
            DrawerCard(
                text: 'SETTINGS',
                color: Color(0xFFF5F7FB),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => SettingsScreen()));
                })
          ]),
    );
  }
}
