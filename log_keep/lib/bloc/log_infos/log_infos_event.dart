import 'package:equatable/equatable.dart';
import 'package:log_keep_shared/log_keep_shared.dart';

abstract class LogInfosEvent extends Equatable {
  const LogInfosEvent();

  @override
  List<Object> get props => [];
}

class LoadLogInfos extends LogInfosEvent {
  final String project;

  LoadLogInfos(this.project);
}

class LogInfosUpdated extends LogInfosEvent {
  final List<LogInfoEntity> logs;

  const LogInfosUpdated(this.logs);

  @override
  List<Object> get props => [logs];

  @override
  String toString() => 'LogInfosUpdated { logs: $logs }';
}
