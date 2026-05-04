import 'package:googleapis/firestore/v1.dart';

extension DocumentExtensions on Document {
  String getId() {
    final n = name;
    if (n == null || n.isEmpty) {
      return '';
    }
    final parts = n.split('/');
    return parts.isNotEmpty ? parts.last : '';
  }
}
