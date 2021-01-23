import 'package:equatable/equatable.dart';
import 'package:log_keep_shared/log_keep_shared.dart';

abstract class LogInfosState extends Equatable {
  final List<LogInfoEntity> logs;

  LogInfosState(this.logs);

  @override
  List<Object> get props => [];
}

class LogInfosLoaded extends LogInfosState {
  LogInfosLoaded(List<LogInfoEntity> logs) : super(logs);

  @override
  List<Object> get props => [logs];

  @override
  String toString() => 'LogInfosLoaded { logs: $logs }';
}

class LogInfosNotLoaded extends LogInfosState {
  LogInfosNotLoaded() : super(List.empty());
}
