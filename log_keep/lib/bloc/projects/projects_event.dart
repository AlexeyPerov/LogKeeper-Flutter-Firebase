import 'package:equatable/equatable.dart';
import 'package:log_keep/repositories/logs_repository.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object> get props => [];
}

class LoadProjects extends ProjectsEvent {
}

class ProjectsUpdated extends ProjectsEvent {
  final List<ProjectInfo> projects;

  const ProjectsUpdated(this.projects);

  @override
  List<Object> get props => [projects];

  @override
  String toString() => 'ProjectsUpdated { projects: $projects }';
}

class SelectProject extends ProjectsEvent {
  final String newSelectedProject;

  const SelectProject(this.newSelectedProject);

  @override
  String toString() => 'SelectProject { newSelectedProject: $newSelectedProject }';
}