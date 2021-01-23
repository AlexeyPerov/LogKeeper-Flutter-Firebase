import 'package:equatable/equatable.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep_shared/log_keep_shared.dart';

abstract class ProjectsState extends Equatable {
  final List<ProjectInfo> projects;
  final String selectedProject;

  ProjectsState(this.projects, this.selectedProject);

  @override
  List<Object> get props => [ projects, selectedProject ];
}

class ProjectsLoading extends ProjectsState {
  ProjectsLoading() : super([defaultProjectInfo], defaultProjectName);
}

class ProjectsLoaded extends ProjectsState {
  ProjectsLoaded(List<ProjectInfo> projects, String selectedProject)
      : super(projects, selectedProject);

  @override
  String toString() => 'ProjectsLoaded { projects: $projects }';
}

class ProjectsNotLoaded extends ProjectsState {
  ProjectsNotLoaded() : super([defaultProjectInfo], defaultProjectName);
}