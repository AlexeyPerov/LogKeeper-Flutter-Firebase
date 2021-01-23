import 'dart:async';
import 'package:googleapis/firestore/v1.dart';
import 'package:log_keep_shared/log_keep_shared.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:googleapis_auth/auth_io.dart';

import '../constants.dart';
import '../server_response.dart';
import '../utilities/document_extensions.dart';
import '../utilities/log_params_parse_utilities.dart';
import '../utilities/value_utilities.dart';

class SaveController implements ResponseImpl {
  const SaveController();
  @override
  Future<shelf.Response> result(shelf.Request request) async {
    AutoRefreshingAuthClient client;

    try {
      client = await clientViaServiceAccount(
          Constants.firebaseCredentials, Constants.firebaseScopes);
    } catch (e) {
      return new ServerResponse('Firebase Auth Failed',
          body: {"error": e.toString()}).error();
    }

    var firestore = new FirestoreApi(client);

    ListDocumentsResponse projectsListResult;

    try {
      projectsListResult = await firestore.projects.databases.documents
          .list(Constants.databaseParentPath, 'projects');
    } catch (e) {
      return new ServerResponse('Unable to retrieve projects list',
          body: {"error": e}).error();
    }

    var logParams = LogParamsParseUtilities.parse(request);
    var project = logParams['project'].stringValue;

    if (!projectsListResult.documents
        .any((element) => element.fields['name'].stringValue == project)) {
      print('Received new project: ' + project);

      var projectDocument = new Document();
      projectDocument.fields = new Map<String, Value>();
      projectDocument.fields['name'] = ValueUtilities.createFromString(project);

      try {
        await firestore.projects.databases.documents.createDocument(
            projectDocument, Constants.databaseParentPath, projectsCollection);
      } catch (e) {
        return new ServerResponse('Error saving project',
            body: {"error": e.toString()}).error();
      }

      print('New project saved');
    } else {
      print('Project ' + project + ' already exists');
    }

    var contentsDocument = new Document();
    contentsDocument.fields = new Map<String, Value>();
    contentsDocument.fields['contents'] = logParams['contents'];

    Document contentsDocumentValue;

    try {
      contentsDocumentValue = await firestore.projects.databases.documents
          .createDocument(contentsDocument, Constants.databaseParentPath,
              logContentsCollection);
    } catch (e) {
      return new ServerResponse('Error saving log contents',
          body: {"error": e.toString()}).error();
    }

    var contentsId = contentsDocumentValue.getId();

    var titleDocument = new Document();
    titleDocument.fields = new Map<String, Value>();
    titleDocument.fields['author'] = logParams['author'];
    titleDocument.fields['title'] = logParams['title'];
    titleDocument.fields['createdAt'] =
        ValueUtilities.createFromDateTime(DateTime.now());
    titleDocument.fields['contentsId'] =
        ValueUtilities.createFromString(contentsId);

    print('Saved log contents with id: ' + contentsId + '. Saving the title.');

    var collectionName = getProjectCollectionName(project);

    Document titleDocumentValue;

    try {
      titleDocumentValue = await firestore.projects.databases.documents
          .createDocument(
              titleDocument, Constants.databaseParentPath, collectionName);
    } catch (e) {
      return new ServerResponse('Error saving log title',
          body: {"error": e.toString()}).error();
    }

    var logId = titleDocumentValue.getId();
    print('Log saved. Id: ' + logId);

    var response = new ServerResponse('Saved',
        body: {"id": logId, "url_format": Constants.serverLogUrlFormat});

    return response.ok();
  }
}
