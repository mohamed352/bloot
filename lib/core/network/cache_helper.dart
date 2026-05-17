import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/network/cache_keys.dart';

@singleton
class CacheHelper {
  CacheHelper(this._prefs) : _secureStorage = const FlutterSecureStorage();

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  Future<bool> saveData({required String key, required String value}) async {
    AppLogger.debug('Saving key: $key', tag: LogTags.cache);
    return _prefs.setString(key, value);
  }

  String? getData({required String key}) {
    return _prefs.getString(key);
  }

  Future<bool> saveBool({required String key, required bool value}) async {
    return _prefs.setBool(key, value);
  }

  bool? getBool({required String key}) {
    return _prefs.getBool(key);
  }

  Future<bool> removeData({required String key}) async {
    AppLogger.debug('Removing key: $key', tag: LogTags.cache);
    return _prefs.remove(key);
  }

  bool containsKey({required String key}) {
    return _prefs.containsKey(key);
  }

  Future<void> saveSecureData({
    required String key,
    required String value,
  }) async {
    AppLogger.debug('Saving secure key: $key', tag: LogTags.cache);
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecureData({required String key}) async {
    return _secureStorage.read(key: key);
  }

  Future<void> deleteSecureData({required String key}) async {
    AppLogger.debug('Deleting secure key: $key', tag: LogTags.cache);
    await _secureStorage.delete(key: key);
  }

  Future<void> clearSecureStorage() async {
    AppLogger.warning('Clearing all secure storage', tag: LogTags.cache);
    await _secureStorage.deleteAll();
  }

  bool get isOnboardingComplete =>
      getBool(key: CacheKeys.onboardingComplete) ?? false;

  bool get isLoggedIn => getData(key: CacheKeys.userId) != null;

  String? get userId => getData(key: CacheKeys.userId);

  bool get isGuest => getBool(key: CacheKeys.isGuest) ?? false;
}
