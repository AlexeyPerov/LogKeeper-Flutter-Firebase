import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/firestore/v1.dart';
import 'dart:io';

import 'package:string_unescape/string_unescape.dart';

class Constants {
  static String get databaseParentPath {
    return Platform.environment['databaseParentPath'];
  }

  static String get serverLogUrlFormat {
    return Platform.environment['serverLogUrlFormat'];
  }

  static ServiceAccountCredentials get firebaseCredentials {
    var privateKeyId = Platform.environment['private_key_id'];
    var privateKey = Platform.environment['private_key'];
    var clientEmail = Platform.environment['client_email'];
    var clientId = Platform.environment['client_id'];

    privateKey = unescape(privateKey);

    var map = new Map<String, String>();
    map["private_key_id"] = privateKeyId;
    map["private_key"] = privateKey;
    map["client_email"] = clientEmail;
    map["client_id"] = clientId;
    map["type"] = "service_account";

    return new ServiceAccountCredentials.fromJson(map);
  }

  static const String projectFallback = 'default';
  static const String httpParamsFallback = 'N/A';
  static const List<String> firebaseScopes = const [
    FirestoreApi.CloudPlatformScope
  ];

  static const String version = '1.0.0';
}
