import 'package:flutter/material.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/app/configs.dart';
import 'package:log_keep/common/widgets/drawer_card.dart';
import 'package:log_keep/repositories/auth_repository.dart';
import 'package:log_keep/screens/add_log/add_log_screen.dart';
import 'package:log_keep/screens/add_log/components/add_log_form.dart';
import 'package:log_keep/screens/error/error_screen.dart';
import 'package:log_keep/screens/home/home_screen.dart';
import 'package:log_keep/screens/settings/settings_screen.dart';
import 'package:proviso/proviso.dart';
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
                color: Theme.of(context).cardColor,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => AddLogScreen(
                              logForm: new AddLogFormParameters())));
                }),
            DrawerCard(
                text: 'REMOTE ADMIN PANEL',
                color: Theme.of(context).cardColor,
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
                color: Theme.of(context).cardColor,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => SettingsScreen()));
                }),
            SizedBox(height: 10),
            ConditionWidget(
              condition: getIt<AuthRepository>().isLoggedIn(),
              widget: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text('Logged in:\n' + getIt<AuthRepository>().loggedInEmail(), maxLines: 2, overflow: TextOverflow.fade, style: TextStyle(fontSize: 13, height: 1.2)),
              ),
            ),
            ConditionWidget(
              condition: getIt<AuthRepository>().isLoggedIn(),
              widget: DrawerCard(
                  text: 'SIGN OUT',
                  color: Theme.of(context).cardColor,
                  onTap: () async {
                    await getIt<AuthRepository>().logout();
                    HomeScreenNavigation.navigate(context);
                  }),
            )
          ]),
    );
  }
}
