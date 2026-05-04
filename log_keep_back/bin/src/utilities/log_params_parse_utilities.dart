import 'package:googleapis/firestore/v1.dart';
import 'package:shelf/shelf.dart' as shelf;

import '../constants.dart';
import 'body_parser_utilities.dart';
import 'value_utilities.dart';

class LogParamsParseUtilities {
  /// Parses new log params into Firebase Value string types
  static Map<String, Value> parse(shelf.Request request) {
    final parsedParams = <String, Value>{};

    final postParams =
        request.context['postParams'] as Map<String, dynamic>? ?? {};
    final postFileParams =
        request.context['postFileParams'] as Map<String, List<dynamic>>? ?? {};

    final title = BodyParserUtilities.tryGetPostParamsValue(
      'title',
      Constants.httpParamsFallback,
      postParams,
      postFileParams,
    );
    final contents = BodyParserUtilities.tryGetPostParamsValue(
      'contents',
      Constants.httpParamsFallback,
      postParams,
      postFileParams,
    );
    final project = BodyParserUtilities.tryGetPostParamsValue(
      'project',
      Constants.projectFallback,
      postParams,
      postFileParams,
    );
    final author = BodyParserUtilities.tryGetPostParamsValue(
      'author',
      Constants.httpParamsFallback,
      postParams,
      postFileParams,
    );

    parsedParams['title'] = ValueUtilities.createFromString(title);
    parsedParams['contents'] = ValueUtilities.createFromString(contents);
    parsedParams['project'] = ValueUtilities.createFromString(project);
    parsedParams['author'] = ValueUtilities.createFromString(author);

    return parsedParams;
  }
}
