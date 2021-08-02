import 'package:equatable/equatable.dart';
import 'package:log_keep/repositories/logs_repository.dart';

abstract class LogContentsState extends Equatable {
  @override
  List<Object> get props => [];
}

class LogContentsLoaded extends LogContentsState {
  final LogAnalysisEntity log;

  LogContentsLoaded(this.log);

  @override
  List<Object> get props => [log];

  @override
  String toString() => 'LogContentsLoaded { log: $log }';
}

class LogContentsNotLoaded extends LogContentsState {}
