import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/bloc/log_contents/log_contents.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/repositories/settings_repository.dart';
import 'package:log_keep/screens/details/services/log_deletion_service.dart';
import 'package:log_keep/screens/home/home_screen.dart';
import 'components/details_drawer.dart';
import 'components/log_view.dart';

bool detailsDrawerOpened = false;

class DetailsScreen extends StatefulWidget {
  final LogDetailsLoadArguments arguments;

  DetailsScreen({@required this.arguments});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LogContentsBloc>(create: (context) {
      return LogContentsBloc(logsRepository: getIt<LogsRepository>())
        ..add(LoadLogContents(widget.arguments.logId));
    }, child: BlocBuilder<LogContentsBloc, LogContentsState>(
        builder: (context, LogContentsState state) {
      if (state is LogContentsLoaded) {
        return Scaffold(
            appBar: kIsWeb ? AppBar() : null,
            drawer: DetailsDrawer(log: state.log),
            onDrawerChanged: (isOpened) {
              setState(() {
                detailsDrawerOpened = isOpened;
              });
            },
            body: getWidgetForLoadedState(context, state.log));
      } else {
        return Scaffold(
          appBar: null,
          body: Align(
              alignment: Alignment.center, child: LinearProgressIndicator()),
        );
      }
    }));
  }

  Widget getWidgetForLoadedState(BuildContext context, LogAnalysisEntity log) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    final limitedView = width <= 1024 || height <= 1024;

    if (kIsWeb && !limitedView) {
      var targetWidth = width > 1024 ? min(width - 150, width) : width;
      return Align(
        alignment: Alignment.center,
        child: Container(
            width: targetWidth,
            child: LogView(
                log: log,
                onDelete: () {
                  deleteLog(context, log);
                },
                settings: getIt<SettingsRepository>())),
      );
    } else {
      return SafeArea(child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
            height:
                constraints.hasInfiniteHeight ? height : constraints.maxHeight,
            child: LogView(
                log: log,
                onDelete: () {
                  deleteLog(context, log);
                },
                settings: getIt<SettingsRepository>()));
      }));
    }
  }

  void deleteLog(BuildContext context, LogAnalysisEntity log) {
    LogDeletionService.requestDeletion(
            context, log.originalLog.project, log.originalLog.info)
        .then((result) => {if (result) HomeScreenNavigation.navigate(context)});
  }
}

class LogDetailsLoadArguments {
  final String logId;

  LogDetailsLoadArguments({@required this.logId});
}
