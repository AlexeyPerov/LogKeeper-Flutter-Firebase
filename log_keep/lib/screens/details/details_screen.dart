import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/bloc/log_contents/log_contents.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep_shared/log_keep_shared.dart';
import 'components/details_drawer.dart';
import 'components/log_view.dart';

class DetailsScreen extends StatelessWidget {
  final LogDetailsLoadArguments arguments;

  DetailsScreen({@required this.arguments});

  @override
  Widget build(BuildContext mainContext) {
    return BlocProvider<LogContentsBloc>(create: (context) {
      return LogContentsBloc(logsRepository: getIt<LogsRepository>())
        ..add(LoadLogContents(arguments.logId));
    }, child: BlocBuilder<LogContentsBloc, LogContentsState>(
        builder: (context, LogContentsState state) {
      if (state is LogContentsLoaded) {
        return Scaffold(
            appBar: kIsWeb ? AppBar() : null,
            drawer: DetailsDrawer(log: state.log),
            body: getWidgetForLoadedState(context, state.log));
      } else {
        return Align(
            alignment: Alignment.center, child: LinearProgressIndicator());
      }
    }));
  }

  Widget getWidgetForLoadedState(BuildContext context, LogEntity log) {
    if (kIsWeb) {
      var width = MediaQuery.of(context).size.width;
      return Align(
        alignment: Alignment.center,
        child: Container(width: min(850, width), child: LogView(log: log)),
      );
    } else {
      var height = MediaQuery.of(context).size.height;
      return SafeArea(child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
            height:
                constraints.hasInfiniteHeight ? height : constraints.maxHeight,
            child: LogView(log: log));
      }));
    }
  }
}

class LogDetailsLoadArguments {
  final String logId;

  LogDetailsLoadArguments({@required this.logId});
}
