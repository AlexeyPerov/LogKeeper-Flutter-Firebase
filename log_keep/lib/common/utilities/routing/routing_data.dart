class RoutingData {
  final String route;
  final Map<String, String> _queryParameters;

  RoutingData({
    required this.route,
    Map<String, String>? queryParameters,
  }) : _queryParameters = queryParameters ?? const {};

  String? operator [](String key) => _queryParameters[key];
}
