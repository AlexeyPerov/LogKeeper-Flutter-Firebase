import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:log_keep/bloc/global/events_stream.dart';
import 'package:log_keep/bloc/global/global_events.dart';
import 'package:log_keep/bloc/projects/projects_event.dart';
import 'package:log_keep/bloc/projects/projects_state.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/repositories/settings_repository.dart';
import 'package:log_keep_shared/log_keep_shared.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final EventsStream eventsStream;
  final LogsRepository logsRepository;
  final SettingsRepository settingsRepository;

  StreamSubscription _projectsSubscription;

  ProjectsBloc(
      {this.eventsStream, this.logsRepository, this.settingsRepository})
      : super(ProjectsLoading());

  @override
  Stream<ProjectsState> mapEventToState(ProjectsEvent event) async* {
    if (event is LoadProjects) {
      yield* _mapLoadProjectsToState(event);
    } else if (event is ProjectsUpdated) {
      yield* _mapProjectsUpdateToState(event);
    } else if (event is SelectProject) {
      yield* _mapSelectProjectToState(event);
    }
  }

  Stream<ProjectsState> _mapLoadProjectsToState(LoadProjects event) async* {
    _projectsSubscription?.cancel();
    _projectsSubscription = logsRepository.getProjects().listen((projects) {
      var result = List<ProjectInfo>.empty(growable: true);

      for (var i = 0; i < projects.length; i++) {
        result.add(ProjectInfo(
            projects[i], logsRepository.getLogsCountByProject(projects[i])));
      }

      add(ProjectsUpdated(result));
    });
  }

  Stream<ProjectsState> _mapProjectsUpdateToState(
      ProjectsUpdated event) async* {
    var selectedProject = settingsRepository.getString('selected_project');

    if (selectedProject.isEmpty ||
        !event.projects
            .any((projectInfo) => projectInfo.project == selectedProject)) {
      selectedProject = event.projects.length > 0
          ? event.projects[0].project
          : defaultProjectName;
    }

    yield ProjectsLoaded(event.projects, selectedProject);

    eventsStream.add(ProjectSelected(selectedProject));
  }

  Stream<ProjectsState> _mapSelectProjectToState(SelectProject event) async* {
    settingsRepository.putString('selected_project', event.newSelectedProject);
    yield ProjectsLoaded(state.projects, event.newSelectedProject);

    eventsStream.add(ProjectSelected(event.newSelectedProject));
  }

  @override
  Future<void> close() {
    _projectsSubscription?.cancel();
    return super.close();
  }
}
