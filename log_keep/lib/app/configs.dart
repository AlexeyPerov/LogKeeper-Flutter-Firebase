import 'package:log_keep/app/app.dart';
import 'package:log_keep/repositories/logs_repository.dart';

String serverUrlFormat() {
  return 'https://${getIt<LogsRepository>().getProjectId()}.web.app'
      '/#/details?id=';
}

String databaseAdminUrl() {
  return 'https://console.firebase.google.com/u/2/'
      'project/${getIt<LogsRepository>().getProjectId()}/firestore';
}
