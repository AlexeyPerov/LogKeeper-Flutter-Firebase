import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/app/theme/theme_constants.dart';
import 'package:log_keep/bloc/global/events_stream.dart';
import 'package:log_keep/bloc/projects/projects.dart';
import 'package:log_keep/bloc/log_infos/log_infos.dart';
import 'package:log_keep/common/utilities/navigator_utilities.dart';
import 'package:log_keep/repositories/auth_repository.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/repositories/settings_repository.dart';
import 'package:log_keep/screens/auth/auth_screen.dart';
import 'package:log_keep/screens/home/components/home_drawer.dart';
import 'dart:math';
import 'components/logs_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authRepository = getIt<AuthRepository>();
    if (!authRepository.isLoggedIn() && authRepository.isRequired()) {
      return TextButton(
          child: Text(
            "Authorize".toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            HomeScreenNavigation.navigate(context);
          });
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProjectsBloc>(
          create: (context) {
            return ProjectsBloc(
                eventsStream: getIt<EventsStream>(),
                logsRepository: getIt<LogsRepository>(),
                settingsRepository: getIt<SettingsRepository>())
              ..add(LoadProjects());
          },
        ),
        BlocProvider<LogInfosBloc>(
          create: (context) {
            return LogInfosBloc(
                eventsStream: getIt<EventsStream>(),
                logsRepository: getIt<LogsRepository>());
          },
        )
      ],
      child: Scaffold(
          appBar: kIsWeb ? AppBar() : null,
          drawer: HomeDrawer(),
          body: BlocBuilder<ProjectsBloc, ProjectsState>(
              builder: (context, ProjectsState state) {
            if (state is ProjectsLoading) {
              return Align(
                  alignment: Alignment.center,
                  child: LinearProgressIndicator());
            }

            var projects = state.projects;

            if (kIsWeb) {
              var width = MediaQuery.of(context).size.width;
              return Align(
                alignment: Alignment.center,
                child: Container(
                    width: min(kMinWebContainerWidth, width),
                    child: LogsList(
                        projects: projects,
                        selectedProject: state.selectedProject)),
              );
            } else {
              return LogsList(
                  projects: projects, selectedProject: state.selectedProject);
            }
          })),
    );
  }
}

class HomeScreenNavigation {
  static navigate(BuildContext context) {
    final authRepository = getIt<AuthRepository>();
    if (authRepository.isLoggedIn() || !authRepository.isRequired()) {
      NavigatorUtilities.pushAndRemoveUntil(context, (context) => HomeScreen());
    } else {
      NavigatorUtilities.pushAndRemoveUntil(context, (context) => AuthScreen());
    }
  }
}