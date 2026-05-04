class BodyParserUtilities {
  static String tryGetPostParamsValue(
    String key,
    String defaultValue,
    Map<String, dynamic> postParams,
    Map<String, List<dynamic>> postFileParams,
  ) {
    var result = defaultValue;

    try {
      if (postParams.containsKey(key)) {
        result = postParams[key] as String;
      } else if (postFileParams.containsKey(key)) {
        result = postFileParams[key]![0].toString();
      }
    } catch (e) {
      print(e);
    }

    return result;
  }
}
