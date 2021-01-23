import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import 'constants.dart';
import 'controllers/save_controller.dart';
import 'server_response.dart';

class RouteHandler {
  static FutureOr<shelf.Response> handler(shelf.Request request) {
    String component;

    try {
      component = request.url.pathSegments.first;
    } catch (e) {
      return new ServerResponse('Error processing request', body: {"error": e})
          .error();
    }

    if (component == 'info') {
      return ServerResponse('Working', body: {
        "version": Constants.version
      }).ok();
    } else if (component == 'save') {
      return SaveController().result(request);
    } else {
      return shelf.Response.notFound(null);
    }
  }
}