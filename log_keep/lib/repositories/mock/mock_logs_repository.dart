import 'dart:async';
import 'package:log_keep/common/utilities/random.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/repositories/mock/mock_utilities.dart';
import 'package:log_keep_shared/log_keep_shared.dart';

class MockLogsRepository extends LogsRepository {
  @override
  void initialize() {}

  @override
  Stream<List<String>> getProjects() {
    final projects = [
      "PROJ 0.15.0",
      "PROJ 0.14.1 DEV",
      "PROJ 0.16.4 Pre Prod",
      "PROJ 0.17.0",
      "PROJ 0.14.2 DEV",
      "PROJ 0.13.0 DRAFT",
      "PROJ 0.12.0",
      "PROJ 0.11.0",
      "PROJ 0.10.0"
    ];

    return Future.value(projects).asStream().asBroadcastStream();
  }

  @override
  Future<void> archiveProject(String project) async {
    await fakeDelay();
  }

  Stream<int> getLogsCountByProject(String project) {
    return Future<int>.value(RandomUtilities.get(0, 300))
        .asStream()
        .asBroadcastStream();
  }

  Stream<List<LogInfoEntity>> getLogsForProject(String project) {
    var logs = List<LogInfoEntity>.empty(growable: true);
    var count = RandomUtilities.get(10, 300);

    for (var i = 0; i < count; i++) {
      logs.add(_createMockLogInfoEntity(i));
    }
    return Future.value(logs).asStream().asBroadcastStream();
  }

  @override
  Future<String> addLog(String project, LogCreationArguments logData) async {
    await fakeDelay();
    return "0";
  }

  @override
  Future removeLog(String project, String id) async {
    await fakeDelay();
  }

  @override
  Future<LogEntity> getLogInProjectById(String project, String id) async {
    await fakeDelay();
    return _createMockLogEntity();
  }

  @override
  Future<LogEntity> getLogById(String id) async {
    await fakeDelay();
    return _createMockLogEntity();
  }

  LogInfoEntity _createMockLogInfoEntity(int i) {
    return LogInfoEntity(
        id: "2u54ngrungefjejfien",
        title:
            "F_SILENT: $i FCM buffer verification failed. Failed to load FCM messages, some messages may have been dropped! "
            "This may be due to, (1) the device being out of space, (2) a crash on a previous run of the application, (3) a change in internal serialization format follow",
        author: "Mike Smith $i",
        createdAt: DateTime.now(),
        contentsId: "0fmbifmbkmkd");
  }

  LogEntity _createMockLogEntity() {
    var info = _createMockLogInfoEntity(0);

    var contents = "11:Enter:StartGameLoadingState:\n"
        "10:Exit:ClearOldCacheState:\n"
        "9:Enter:ClearOldCacheState:\n"
        "8:Exit:StartSessionState:\n"
        "7:Enter:ServerRoutingState:\n"
        "6:Enter:AwaitGameFullLoadingState:\n"
        "5:Enter:StartSessionState:\n"
        "4:Exit:InitAppState:\n"
        "3:Enter:FlowAwaitLoadingState:\n"
        "2:Enter:InitAppState:\n"
        "1:Exit:GameEntryState:\n"
        "0:Enter:GameEntryState\n"
        "|34|18:13:36.7483|[Action: Exit:StartSessionState]"
        "StateSequence.ActivateState => InjectableStateBase`1.OnExit => DiagnosticsService.LogMajorLowLog\n"
        "|35|18:13:36.7483|[Action: Some cheat has been used here]"
        "StateSequence.ActivateState => InjectableStateBase`1.OnExit => DiagnosticsService.LogMajorLowLog\n"
        "|36|18:13:36.7499|[StartSessionState] OnExit"
        "StateSequence.ActivateState => StateSequence.ActivateState => StateSequence.ActivateState\n"
        "|37|18:13:36.7531|[Action: Enter:ClearOldCacheState]"
        "ClearOldCacheState.OnEnter => InjectableStateBase`1.OnEnter => DiagnosticsService.LogMajorLowLog\n"
        "|38|18:13:36.7549|[ClearOldCacheState] WARNING!"
        "StateSequence.ActivateState => StateSequence.ActivateState => ClearOldCacheState.OnEnter\n"
        "|39|18:13:36.7562|[Action: Exit:ClearOldCacheState]"
        "StateSequence.ActivateState => InjectableStateBase`1.OnExit => DiagnosticsService.LogMajorLowLog\n"
        "|40|18:13:36.7579|[ClearOldCacheState] OnExit"
        "StateSequence.ActivateState => StateSequence.ActivateState => StateSequence.ActivateState\n"
        "|41|18:13:36.7621|[Action: Enter:StartGameLoadingState]"
        "StartGameLoadingState.OnEnter => InjectableStateBase`1.OnEnter => DiagnosticsService.LogMajorLowLog\n"
        "|42|18:13:36.7637|[StartGameLoadingState] OnEnter"
        "StateSequence.ActivateState => StateSequence.ActivateState => StartGameLoadingState.OnEnter\n"
        "|43|18:13:36.7667|[UIManager] Initialized"
        "StartGameLoadingState.OnEnter => ApplicationService.RegisterDisposableService => DisposableMonoBehaviourService.InitializeService\n"
        "|44|18:13:36.7637|[StartGameLoadingState]"
        "FCM buffer verification failed\n"
        "|45|18:13:36.7637|[Tutorial step passed]"
        "Successfully\n";

    var count = RandomUtilities.get(2, 5);

    for (var i = 0; i < count; i++) {
      contents += contents;
    }

    contents =
        "Report dated 08/06/2021 18:13 from Android [Build:910] of [F_SILENT: FCM buffer verification failed. Failed to load FCM messages, some messages may have been dropped! This may be due to, (1) the device being out of space, (2) a crash on a previous run of the application, (3) a change in internal serialization format follow]" +
            "\n" +
            contents;

    var logData =
        new LogContentsEntity(id: "0fedgrfhdhhdhf", contents: contents);

    return new LogEntity(project: "Test Project", info: info, data: logData);
  }

  @override
  String getProjectId() {
    return "mock";
  }
}
