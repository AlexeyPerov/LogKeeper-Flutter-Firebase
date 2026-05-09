import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:log_keep/bloc/global/events_stream.dart';
import 'package:log_keep/repositories/auth_repository.dart';
import 'package:log_keep/repositories/settings_repository.dart';
import 'package:log_keep/screens/auth/auth_screen.dart';
import 'package:log_keep/screens/details/details_screen.dart';
import 'package:log_keep/screens/error/error_screen.dart';
import 'package:log_keep/screens/home/home_screen.dart';
import 'package:log_keep/app/theme/themes.dart';
import 'package:log_keep/common/utilities/routing/routing_extensions.dart';
import 'app/app.dart';
import 'app/options/app_options.dart';
import 'app/theme/theme_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    WebViewPlatform.instance ??= WebWebViewPlatform();
  }

  try {
    getIt.registerSingleton<EventsStream>(CommonEventsStream());
    getIt.registerSingleton<SettingsRepository>(HiveSettingsRepository());

    await getIt.get<SettingsRepository>().initialize();
    await App.initializeApp();

    runApp(const AppWidget());
  } catch (e, st) {
    debugPrintStack(stackTrace: st, label: e.toString());
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const ErrorScreen(),
      ),
    );
  }
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) => ModelBinding(
        initialModel: AppOptions(
          themeMode: ThemeMode.values[getIt
              .get<SettingsRepository>()
              .getInt('theme_mode', defaultValue: ThemeMode.system.index)],
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
      title: 'Logs',
      themeMode: AppOptions.of(context).themeMode,
      theme: AppThemeData.lightThemeData.copyWith(
        platform: AppOptions.of(context).platform,
      ),
      darkTheme: AppThemeData.darkThemeData.copyWith(
        platform: AppOptions.of(context).platform,
      ),
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    var routingData = name.getRoutingData;
    switch (routingData.route) {
      case '/details':
        return MaterialPageRoute(
          builder: (context) => DetailsScreen(
            arguments:
                LogDetailsLoadArguments(logId: routingData['id'] ?? ''),
          ),
        );
    }
    final authRepository = getIt<AuthRepository>();
    if (authRepository.isLoggedIn() || !authRepository.isRequired()) {
      return MaterialPageRoute(builder: (context) => HomeScreen());
    } else {
      return MaterialPageRoute(builder: (context) => AuthScreen());
    }
  }
}
