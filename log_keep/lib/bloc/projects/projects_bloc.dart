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
  ProjectsBloc({
    required this.eventsStream,
    required this.logsRepository,
    required this.settingsRepository,
  }) : super(ProjectsLoading()) {
    on<LoadProjects>(_onLoadProjects);
    on<ProjectsUpdated>(_onProjectsUpdated);
    on<SelectProject>(_onSelectProject);
  }

  final EventsStream eventsStream;
  final LogsRepository logsRepository;
  final SettingsRepository settingsRepository;

  StreamSubscription<dynamic>? _projectsSubscription;

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectsState> emit,
  ) async {
    await _projectsSubscription?.cancel();
    _projectsSubscription = logsRepository.getProjects().listen((projects) {
      var result = List<ProjectInfo>.empty(growable: true);

      for (var i = 0; i < projects.length; i++) {
        result.add(ProjectInfo(
            projects[i], logsRepository.getLogsCountByProject(projects[i])));
      }

      add(ProjectsUpdated(result));
    });
  }

  void _onProjectsUpdated(
    ProjectsUpdated event,
    Emitter<ProjectsState> emit,
  ) {
    var selectedProject = settingsRepository.getString('selected_project');

    if (selectedProject.isEmpty ||
        !event.projects
            .any((projectInfo) => projectInfo.project == selectedProject)) {
      selectedProject = event.projects.isNotEmpty
          ? event.projects[0].project
          : defaultProjectName;
    }

    emit(ProjectsLoaded(event.projects, selectedProject));

    eventsStream.add(ProjectSelected(selectedProject));
  }

  void _onSelectProject(
    SelectProject event,
    Emitter<ProjectsState> emit,
  ) {
    settingsRepository.putString('selected_project', event.newSelectedProject);
    emit(ProjectsLoaded(state.projects, event.newSelectedProject));

    eventsStream.add(ProjectSelected(event.newSelectedProject));
  }

  @override
  Future<void> close() {
    _projectsSubscription?.cancel();
    return super.close();
  }
}
