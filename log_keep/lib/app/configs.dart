import 'package:log_keep/app/app.dart';

String serverUrlFormat() {
  return 'https://${firebaseApp.options.projectId}.web.app/#/details?id=';
}

String databaseAdminUrl() {
  return 'https://console.firebase.google.com/u/2/project/${firebaseApp.options.projectId}/firestore';
}
