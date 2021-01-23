import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class SettingsRepository {
  Future initialize();
  String get(String key, {String defaultValue = ''});
  void put(String key, String value);
}

class HiveSettingsRepository extends SettingsRepository {
  final String _boxName = 'settings';

  @override
  Future initialize() async {
    if (!kIsWeb) {
      var directory = await pathProvider.getApplicationDocumentsDirectory();
      Hive.init(directory.path);
    }
    await Hive.openBox(_boxName);
  }

  @override
  String get(String key, {String defaultValue = ''}) {
    return Hive.box(_boxName).get(key, defaultValue: defaultValue);
  }

  @override
  void put(String key, String value) {
    Hive.box(_boxName).put(key, value);
  }
}