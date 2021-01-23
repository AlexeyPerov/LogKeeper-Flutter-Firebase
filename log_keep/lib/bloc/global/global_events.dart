import 'package:equatable/equatable.dart';

abstract class GlobalEvent extends Equatable {
  const GlobalEvent();

  @override
  List<Object> get props => [];
}

class ProjectSelected extends GlobalEvent {
  final String project;

  ProjectSelected(this.project);
}