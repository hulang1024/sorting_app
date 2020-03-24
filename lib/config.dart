import 'package:shared_preferences/shared_preferences.dart';

/// 配置管理。
class ConfigurationManager {
  static final Future<SharedPreferences> _prefsFuture = SharedPreferences.getInstance();

  /// 返回配置对象，通过它可以存取配置项。
  static Future<SharedPreferences> configuration() {
    return _prefsFuture;
  }

  static Future<bool> clear() {
    return _prefsFuture.then((prefs) => prefs.clear());
  }
}