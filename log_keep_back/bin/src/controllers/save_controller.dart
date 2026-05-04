import 'dart:async';

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:log_keep_shared/log_keep_shared.dart';
import 'package:shelf/shelf.dart' as shelf;

import '../constants.dart';
import '../server_response.dart';
import '../utilities/document_extensions.dart';
import '../utilities/log_params_parse_utilities.dart';
import '../utilities/value_utilities.dart';

class SaveController implements ResponseImpl {
  const SaveController();

  @override
  Future<shelf.Response> result(shelf.Request request) async {
    late final AutoRefreshingAuthClient client;

    try {
      client = await clientViaServiceAccount(
          Constants.firebaseCredentials, Constants.firebaseScopes);
    } catch (e) {
      return ServerResponse('Firebase Auth Failed',
          body: {'error': e.toString()}).error();
    }

    final firestore = FirestoreApi(client);

    late final ListDocumentsResponse projectsListResult;

    try {
      projectsListResult = await firestore.projects.databases.documents
          .list(Constants.databaseParentPath, 'projects');
    } catch (e) {
      return ServerResponse('Unable to retrieve projects list',
          body: {'error': e}).error();
    }

    final logParams = LogParamsParseUtilities.parse(request);
    final project = logParams['project']!.stringValue!;

    final docs = projectsListResult.documents ?? [];
    if (!docs.any((element) =>
        element.fields?['name']?.stringValue == project)) {
      print('Received new project: $project');

      final projectDocument = Document();
      projectDocument.fields = <String, Value>{};
      projectDocument.fields!['name'] = ValueUtilities.createFromString(project);

      try {
        await firestore.projects.databases.documents.createDocument(
            projectDocument, Constants.databaseParentPath, projectsCollection);
      } catch (e) {
        return ServerResponse('Error saving project',
            body: {'error': e.toString()}).error();
      }

      print('New project saved');
    } else {
      print('Project $project already exists');
    }

    final contentsDocument = Document();
    contentsDocument.fields = <String, Value>{};
    contentsDocument.fields!['contents'] = logParams['contents']!;

    late final Document contentsDocumentValue;

    try {
      contentsDocumentValue = await firestore.projects.databases.documents
          .createDocument(contentsDocument, Constants.databaseParentPath,
              logContentsCollection);
    } catch (e) {
      return ServerResponse('Error saving log contents',
          body: {'error': e.toString()}).error();
    }

    final contentsId = contentsDocumentValue.getId();

    final titleDocument = Document();
    titleDocument.fields = <String, Value>{};
    titleDocument.fields!['author'] = logParams['author']!;
    titleDocument.fields!['title'] = logParams['title']!;
    titleDocument.fields!['createdAt'] =
        ValueUtilities.createFromDateTime(DateTime.now());
    titleDocument.fields!['contentsId'] =
        ValueUtilities.createFromString(contentsId);

    print('Saved log contents with id: $contentsId. Saving the title.');

    final collectionName = getProjectCollectionName(project);

    late final Document titleDocumentValue;

    try {
      titleDocumentValue = await firestore.projects.databases.documents
          .createDocument(
              titleDocument, Constants.databaseParentPath, collectionName);
    } catch (e) {
      return ServerResponse('Error saving log title',
          body: {'error': e.toString()}).error();
    }

    final logId = titleDocumentValue.getId();
    print('Log saved. Id: $logId');

    final response = ServerResponse('Saved',
        body: {'id': logId, 'url_format': Constants.serverLogUrlFormat});

    return response.ok();
  }
}
