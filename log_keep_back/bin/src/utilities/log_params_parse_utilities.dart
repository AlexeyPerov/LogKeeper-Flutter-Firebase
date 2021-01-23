import 'package:shelf/shelf.dart' as shelf;
import 'package:googleapis/firestore/v1.dart';

import '../constants.dart';
import 'body_parser_utilities.dart';
import 'value_utilities.dart';

class LogParamsParseUtilities {
  // Parses new log params into Firebase Value string types
  static Map<String, Value> parse(shelf.Request request) {
    Map<String, Value> parsedParams = new Map<String, Value>();

    var postParams = request.context['postParams'] as Map<String, dynamic>;
    var postFileParams =
        request.context['postFileParams'] as Map<String, List<dynamic>>;

    var title = BodyParserUtilities.tryGetPostParamsValue(
        'title', Constants.httpParamsFallback, postParams, postFileParams);
    var contents = BodyParserUtilities.tryGetPostParamsValue(
        'contents', Constants.httpParamsFallback, postParams, postFileParams);
    var project = BodyParserUtilities.tryGetPostParamsValue(
        'project', Constants.projectFallback, postParams, postFileParams);
    var author = BodyParserUtilities.tryGetPostParamsValue(
        'author', Constants.httpParamsFallback, postParams, postFileParams);

    parsedParams['title'] = ValueUtilities.createFromString(title);
    parsedParams['contents'] = ValueUtilities.createFromString(contents);
    parsedParams['project'] = ValueUtilities.createFromString(project);
    parsedParams['author'] = ValueUtilities.createFromString(author);

    return parsedParams;
  }
}
