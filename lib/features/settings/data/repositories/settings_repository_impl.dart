import 'package:injectable/injectable.dart';

import 'package:bloot/core/network/cache_helper.dart';
import 'package:bloot/core/network/cache_keys.dart';
import 'package:bloot/features/settings/domain/repositories/settings_repository.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required CacheHelper cacheHelper})
    : _cacheHelper = cacheHelper;

  final CacheHelper _cacheHelper;

  static const List<String> _settingsKeys = [
    CacheKeys.voiceChatEnabled,
    CacheKeys.cameraEnabled,
    CacheKeys.autoRotateGame,
    CacheKeys.soundEffectsEnabled,
    CacheKeys.backgroundMusicEnabled,
    CacheKeys.showOnlineStatus,
    CacheKeys.gameSpeedDefault,
    CacheKeys.speakerMode,
    CacheKeys.profileVisibility,
  ];

  static const List<String> _boolKeys = [
    CacheKeys.voiceChatEnabled,
    CacheKeys.cameraEnabled,
    CacheKeys.autoRotateGame,
    CacheKeys.soundEffectsEnabled,
    CacheKeys.backgroundMusicEnabled,
    CacheKeys.showOnlineStatus,
  ];

  static const List<String> _stringKeys = [
    CacheKeys.gameSpeedDefault,
    CacheKeys.speakerMode,
    CacheKeys.profileVisibility,
  ];

  @override
  Future<Map<String, dynamic>> loadSettings() async {
    final settings = <String, dynamic>{};
    for (final key in _boolKeys) {
      settings[key] = _cacheHelper.getBool(key: key) ?? _defaultForKey(key);
    }
    for (final key in _stringKeys) {
      settings[key] = _cacheHelper.getData(key: key) ?? _defaultStringForKey(key);
    }
    return settings;
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await _cacheHelper.saveBool(key: key, value: value);
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _cacheHelper.saveData(key: key, value: value);
  }

  @override
  Future<String> getString(String key, {String defaultValue = ''}) async {
    return _cacheHelper.getData(key: key) ?? defaultValue;
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return _cacheHelper.getBool(key: key) ?? defaultValue;
  }

  @override
  Future<void> clearSettings() async {
    for (final key in _settingsKeys) {
      await _cacheHelper.removeData(key: key);
    }
  }

  bool _defaultForKey(String key) {
    switch (key) {
      case CacheKeys.voiceChatEnabled:
      case CacheKeys.autoRotateGame:
      case CacheKeys.soundEffectsEnabled:
      case CacheKeys.showOnlineStatus:
        return true;
      case CacheKeys.cameraEnabled:
      case CacheKeys.backgroundMusicEnabled:
        return false;
      default:
        return false;
    }
  }

  String _defaultStringForKey(String key) {
    switch (key) {
      case CacheKeys.gameSpeedDefault:
        return 'normal';
      case CacheKeys.speakerMode:
        return 'speaker';
      case CacheKeys.profileVisibility:
        return 'everyone';
      default:
        return '';
    }
  }
}
