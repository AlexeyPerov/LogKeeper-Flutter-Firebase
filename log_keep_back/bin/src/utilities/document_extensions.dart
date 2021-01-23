import 'package:googleapis/firestore/v1.dart';

extension DocumentExtensions on Document {
  String getId() {
    if (this == null) {
      return null;
    }

    String id = "";

    if (this.name.isNotEmpty) {
      var parts = this.name.split('/');
      id = parts.isNotEmpty ? parts.last : "";
    }

    return id;
  }
}