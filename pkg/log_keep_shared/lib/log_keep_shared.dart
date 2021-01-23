class LogEntity {
  String project;

  LogInfoEntity info;
  LogContentsEntity data;

  LogEntity({this.project, this.info, this.data});

  @override
  String toString() => 'LogEntity { $project ${info.id} }';
}

class LogInfoEntity {
  String id;
  String title;
  String author;
  DateTime createdAt;
  String contentsId;

  LogInfoEntity({this.id, this.title, this.author,
    this.createdAt, this.contentsId});

  @override
  String toString() => 'LogInfoEntity { $id $createdAt }';
}

class LogContentsEntity {
  String id;
  String contents;

  LogContentsEntity({this.id, this.contents});
}

String getProjectCollectionName(String project) {
  var projectPrefix = project.replaceAll(' ', '_').toLowerCase();
  return projectPrefix + '_logs';
}

const String projectsCollection = 'projects';
const String logContentsCollection = 'logs';
const String defaultProjectName = 'Default';
const String defaultNotAvailableValue = 'N/A';
