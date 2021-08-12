import 'package:equatable/equatable.dart';
import 'package:log_keep/repositories/logs_repository.dart';

abstract class LogContentsEvent extends Equatable {
  const LogContentsEvent();

  @override
  List<Object> get props => [];
}

class LoadLogContents extends LogContentsEvent {
  final String id;

  LoadLogContents(this.id);
}

class LogContentsUpdated extends LogContentsEvent {
  final LogAnalysisEntity log;

  const LogContentsUpdated(this.log);

  @override
  List<Object> get props => [log];

  @override
  String toString() => 'LogContentsUpdated { log: $log }';
}
