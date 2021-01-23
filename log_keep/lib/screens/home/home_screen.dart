import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/app/theme/theme_constants.dart';
import 'package:log_keep/bloc/global/events_stream.dart';
import 'package:log_keep/bloc/projects/projects.dart';
import 'package:log_keep/bloc/log_infos/log_infos.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/repositories/settings_repository.dart';
import 'package:log_keep/screens/home/components/home_drawer.dart';
import 'dart:math';
import 'components/logs_list.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
