import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_cache/firestore_cache.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep_shared/log_keep_shared.dart';
import 'package:log_keep/common/utilities/map_extensions.dart';

abstract class LogsRepository {
  void initialize();
  Stream<List<LogInfoEntity>> getLogsForProject(String project);
  Future<String> addLog(String project, LogCreationArguments logData);
  Future removeLog(String project, String id);
  Future<LogEntity> getLogInProjectById(String project, String id);
  Future<LogEntity> getLogById(String id);
  Stream<List<String>> getProjects();
  Stream<int> getLogsCountByProject(String project);
  Future<void> archiveProject(String project);
  String getProjectId();
}

class FirestoreLogsRepository extends LogsRepository {
  FirebaseFirestore _provider;
  CollectionReference _projects;

  FirestoreLogsRepository(FirebaseFirestore provider) {
    _provider = provider;
  }

  @override
  void initialize() {
    _projects = _provider.collection('projects');
  }

  @override
  Stream<List<String>> getProjects() {
    return _provider.collection('projects').snapshots().map((snapshot) {
      if (snapshot.docs == null || snapshot.docs.isEmpty) {
        return List<String>.filled(1, defaultProjectName, growable: false);
      }
      var projects = snapshot.docs
          .map((doc) {
            return doc['name'].toString();
          })
          .toSet()
          .toList(growable: false);

      projects.sort((a, b) => b.compareTo(a));

      return projects;
    });
  }

  @override
  Future<void> archiveProject(String project) async {
    var projectQuery = await _projects.where('name', isEqualTo: project).get();

    if (projectQuery.size == 0) {
      return Future.value();
    }

    for (var doc in projectQuery.docs) {
      await _projects.doc(doc.id).delete();
    }
  }

  Stream<int> getLogsCountByProject(String project) {
    var collectionName = getProjectCollectionName(project);
    return _provider
        .collection(collectionName)
        .snapshots()
        .map((event) => event.docs.length);
  }

  Stream<List<LogInfoEntity>> getLogsForProject(String project) {
    var collectionName = getProjectCollectionName(project);
    return _provider.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((document) {
        return LogInfoEntity(
            id: document.id,
            title: document['title'].toString(),
            author: document['author'].toString(),
            contentsId: document['contentsId'].toString(),
            createdAt: (document['createdAt'] as Timestamp).toDate());
      }).toList();
    });
  }

  @override
  Future<String> addLog(String project, LogCreationArguments logData) async {
    var projectQuery = await _projects.where('name', isEqualTo: project).get();

    if (projectQuery.size == 0) {
      await _projects.add({'name': project});
    }

    var addedContents =
        await _provider.collection('logs').add({'contents': logData.contents});

    var collectionName = getProjectCollectionName(project);
    var projectLogsCollection = _provider.collection(collectionName);

    var future = projectLogsCollection.add({
      'author': logData.author,
      'title': logData.title,
      'contentsId': addedContents.id,
      'createdAt': logData.createdAt
    });

    future
        .then((_) => logger.i('Log ' + logData.title + ' saved'))
        .catchError((e) => logger.e('Log save error: ' + e));

    var ref = await future;

    return ref.id;
  }

  @override
  Future removeLog(String project, String id) async {
    var collectionName = getProjectCollectionName(project);

    var logInfoQuery = await _provider.collection(collectionName).doc(id).get();

    if (!logInfoQuery.exists) {
      logger.i('Log with id ' + id + ' was not found in project ' + project);
      return Future.value(null);
    }

    await _provider.collection('logs').doc(logInfoQuery['contentsId']).delete();

    logger.i('Log contents ' + id + ' has been deleted');

    await _provider.collection(collectionName).doc(id).delete();

    logger.i('Log ' + id + ' has been deleted');
  }

  @override
  Future<LogEntity> getLogInProjectById(String project, String id) async {
    logger.i('looking for log: ' + id + ' in project ' + project);
    var collectionName = getProjectCollectionName(project);

    var logInfoRef = _provider.collection(collectionName).doc(id);

    var logInfoQuery = await FirestoreCache.getDocument(logInfoRef);

    if (!logInfoQuery.exists) {
      return Future.value(null);
    }

    var logInfoData = logInfoQuery.data();
    Timestamp timestamp = logInfoData.getValueOrDefault(
        'createdAt', DateTime.fromMicrosecondsSinceEpoch(0));

    var info = new LogInfoEntity(
        id: logInfoQuery.id,
        author:
            logInfoData.getValueOrDefault('author', defaultNotAvailableValue),
        title: logInfoData.getValueOrDefault('title', defaultNotAvailableValue),
        contentsId: logInfoQuery['contentsId'],
        createdAt: timestamp.toDate());

    var logDataRef = _provider.collection('logs').doc(info.contentsId);

    var logDataQuery = await FirestoreCache.getDocument(logDataRef);

    if (!logInfoQuery.exists) {
      return Future.error(
          'Log data with id ' + info.contentsId + ' was not found');
    }

    var logData = new LogContentsEntity(
        id: logDataQuery.id,
        contents: logDataQuery.data().getValueOrDefault('contents', ''));

    var result = new LogEntity(project: project, info: info, data: logData);

    return result;
  }

  @override
  Future<LogEntity> getLogById(String id) async {
    logger.i('Looking for log: ' + id);

    var projects = await _projects.get();

    LogEntity result;

    if (projects.size > 0) {
      for (var i = 0; i < projects.docs.length; i++) {
        var document = projects.docs[i];

        var project = document['name'];
        var log = await getLogInProjectById(project, id);

        if (log != null && result == null) {
          result = log;
          break;
        }
      }
    }

    return result;
  }

  @override
  String getProjectId() {
    return firebaseApp.options.projectId;
  }
}

class LogCreationArguments {
  String author;
  String title;
  String contents;
  DateTime createdAt;

  LogCreationArguments(
      {this.author, this.title, this.contents, this.createdAt});
}

class ProjectInfo {
  final String project;
  final Stream<int> logsCount;

  ProjectInfo(this.project, this.logsCount);

  @override
  String toString() => 'ProjectInfo { project: $project }';
}

ProjectInfo get defaultProjectInfo {
  return ProjectInfo(defaultProjectName, defaultStream());
}

Stream<int> defaultStream() async* {
  yield 0;
}

class LogAnalysisEntity {
  final LogEntity originalLog;
  final List<LogLine> lines;

  final int alarmsCount;
  final int cheatCount;
  final int modelCount;
  final int tutorialCount;

  LogAnalysisEntity(this.originalLog, this.lines, this.alarmsCount,
      this.cheatCount, this.modelCount, this.tutorialCount);
}

class LogLine {
  final int index;
  final String contents;
  final bool alarm;
  final bool cheat;
  final bool model;
  final bool tutorial;

  LogLine(this.index, this.contents, this.alarm, this.cheat, this.model,
      this.tutorial);
}
