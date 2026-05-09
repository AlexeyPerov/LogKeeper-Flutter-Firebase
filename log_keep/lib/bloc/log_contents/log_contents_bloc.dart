import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:log_keep/bloc/log_contents/log_contents.dart';
import 'package:log_keep/bloc/log_contents/log_contents_parser.dart';
import 'package:log_keep/repositories/logs_repository.dart';

class LogContentsBloc extends Bloc<LogContentsEvent, LogContentsState> {
  LogContentsBloc({required this.logsRepository}) : super(LogContentsNotLoaded()) {
    on<LoadLogContents>(_onLoadLogContents);
    on<LogContentsUpdated>(_onLogContentsUpdated);
  }

  final LogsRepository logsRepository;

  Future<void> _onLoadLogContents(
    LoadLogContents event,
    Emitter<LogContentsState> emit,
  ) async {
    final log = await logsRepository.getLogById(event.id);
    if (log == null) {
      return;
    }

    final parsed = await compute(parseLogContentsIsolate, log.data.contents);

    add(LogContentsUpdated(LogAnalysisEntity(
      log,
      parsed.lines,
      parsed.alarmsCount,
      parsed.cheatCount,
      parsed.modelCount,
      parsed.tutorialCount,
    )));
  }

  void _onLogContentsUpdated(
    LogContentsUpdated event,
    Emitter<LogContentsState> emit,
  ) {
    emit(LogContentsLoaded(event.log));
  }
}
