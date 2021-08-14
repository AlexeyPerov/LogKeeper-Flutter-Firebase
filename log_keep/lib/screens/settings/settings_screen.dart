import 'package:flutter/material.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/app/options/app_options.dart';
import 'package:log_keep/app/theme/theme_constants.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:log_keep/common/utilities/navigator_utilities.dart';
import 'package:log_keep/repositories/settings_repository.dart';
import 'package:log_keep/screens/home/home_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 142),
          SizedBox(height: 30),
          Row(
            children: [
              Spacer(),
              drawThemeModeCard(context, Icons.sync, ThemeMode.system),
              drawThemeModeCard(context, Icons.lightbulb_outline, ThemeMode.light),
              drawThemeModeCard(context, Icons.lightbulb, ThemeMode.dark),
              Spacer()
            ],
          ),
          SizedBox(height: 40),
          TextButton(
              child: Text(
                "Back To Home".toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                NavigatorUtilities.pushAndRemoveUntil(
                    context, (c) => HomeScreen());
              }),
        ],
      ),
    ));
  }
}

Widget drawThemeModeCard(BuildContext context, IconData icon, ThemeMode themeMode) {
  var selected = AppOptions.of(context).themeMode == themeMode;

  return GestureDetector(
    onTap: () {
      AppOptions.update(
          context, AppOptions.of(context).copyWith(themeMode: themeMode));
      getIt.get<SettingsRepository>().putInt("theme_mode", themeMode.index);
    },
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      height: 120.0,
      width: 250.0,
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
            padding: EdgeInsets.only(left: 25.0, top: 30.0),
            child: Text(
                themeMode
                    .toString()
                    .replaceAll("ThemeMode.", "")
                    .toUpperCase(),
                overflow: TextOverflow.fade,
                maxLines: 2),
          ),
          Padding(
              padding: EdgeInsets.only(left: 25.0, bottom: 30.0),
              child: Icon(icon, size: 20))
        ],
      ),
    ),
  );
}
