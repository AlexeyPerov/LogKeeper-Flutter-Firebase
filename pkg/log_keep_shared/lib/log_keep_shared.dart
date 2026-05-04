class LogEntity {
  String project;

  LogInfoEntity info;
  LogContentsEntity data;

  LogEntity({required this.project, required this.info, required this.data});

  @override
  String toString() => 'LogEntity { $project ${info.id} }';
}

class LogInfoEntity {
  String id;
  String title;
  String author;
  DateTime createdAt;
  String contentsId;

  LogInfoEntity(
      {required this.id,
      required this.title,
      required this.author,
      required this.createdAt,
      required this.contentsId});

  @override
  String toString() => 'LogInfoEntity { $id $createdAt }';
}

class LogContentsEntity {
  String id;
  String contents;

  LogContentsEntity({required this.id, required this.contents});
}

String getProjectCollectionName(String project) {
  var projectPrefix = project.replaceAll(' ', '_').toLowerCase();
  return '${projectPrefix}_logs';
}

const String projectsCollection = 'projects';
const String logContentsCollection = 'logs';
const String defaultProjectName = 'Default';
const String defaultNotAvailableValue = 'N/A';
