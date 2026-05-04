import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';

/// Populates [Request.context] with `postParams` and `postFileParams`, matching
/// the behavior previously provided by `shelf_body_parser`.
Middleware bodyParser({bool storeOriginalBuffer = false}) {
  return (Handler inner) {
    return (Request request) async {
      final postParams = <String, dynamic>{};
      final postFileParams = <String, List<dynamic>>{};

      if (request.url.hasQuery) {
        postParams.addAll(Uri.splitQueryString(request.url.query));
      }

      final contentTypeHeader = request.headers['content-type'];
      final contentType = contentTypeHeader != null
          ? MediaType.parse(contentTypeHeader)
          : null;

      if (contentType != null) {
        if (contentType.mimeType == 'application/json') {
          final body = await request.readAsString();
          final decoded = json.decode(body);
          if (decoded is Map) {
            for (final entry in decoded.entries) {
              postParams[entry.key.toString()] = entry.value;
            }
          }
        } else if (contentType.mimeType == 'application/x-www-form-urlencoded') {
          final body = await request.readAsString();
          postParams.addAll(Uri.splitQueryString(body));
        } else if (contentType.type == 'multipart' &&
            contentType.parameters.containsKey('boundary')) {
          final form = FormDataRequest.of(request);
          if (form != null) {
            await for (final data in form.formData) {
              final name = data.name;
              final text = await data.part.readString();
              final list = postFileParams.putIfAbsent(name, () => <dynamic>[]);
              list.add(text);
            }
          }
        }
      }

      final context = <String, Object?>{
        ...request.context,
        'postParams': postParams,
        'postFileParams': postFileParams,
      };
      if (storeOriginalBuffer) {
        context['originalBuffer'] = null;
      }

      return inner(request.change(context: context));
    };
  };
}
