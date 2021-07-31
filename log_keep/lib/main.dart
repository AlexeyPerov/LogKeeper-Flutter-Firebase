import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:log_keep/bloc/global/events_stream.dart';
import 'package:log_keep/repositories/settings_repository.dart';
import 'package:log_keep/screens/details/details_screen.dart';
import 'package:log_keep/screens/error/error_screen.dart';
import 'package:log_keep/screens/home/home_screen.dart';
import 'package:log_keep/screens/splash/splash_screen.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:log_keep/common/utilities/routing/routing_extensions.dart';
import 'app/app.dart';
import 'app/options/app_options.dart';
import 'app/theme/theme_constants.dart';

void main() {
  getIt.registerSingleton<EventsStream>(CommonEventsStream());
  getIt.registerSingleton<SettingsRepository>(HiveSettingsRepository());

  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  final Future _appInitialization;

  AppWidget() : _appInitialization = App.initializeApp();

  @override
  Widget build(BuildContext context) => ModelBinding(
    initialModel: AppOptions(
      themeMode: ThemeMode.system,
      textScaleFactor: systemTextScaleFactorOption,
      timeDilation: timeDilation,
      platform: defaultTargetPlatform,
      isTestMode: false,
    ),
    child: Builder(
      builder: (context) {
        return _createApp(context);
      },
    ),
  );

  MaterialApp _createApp(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Log Keeper',
      themeMode: AppOptions.of(context).themeMode,
      theme: AppThemeData.lightThemeData.copyWith(
        platform: AppOptions.of(context).platform,
      ),
      darkTheme: AppThemeData.darkThemeData.copyWith(
        platform: AppOptions.of(context).platform,
      ),
      initialRoute: HomeScreen.routeName,
      onGenerateRoute: _generateRoute,
    );
  }

  FutureBuilder _redirectOnAppInit(RouteToWidget routeTo) {
    return FutureBuilder(
      future: _appInitialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorScreen();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return routeTo();
        }

        return SplashScreen();
      },
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    var routingData = settings.name.getRoutingData;
    switch (routingData.route) {
      case '/details':
        return MaterialPageRoute(
            builder: (context) => _redirectOnAppInit(() => DetailsScreen(
                arguments: LogDetailsLoadArguments(logId: routingData['id']))));
        break;
    }

    return MaterialPageRoute(
      builder: (context) => _redirectOnAppInit(() => HomeScreen()),
    );
  }
}

typedef Widget RouteToWidget();
