/// Repository contract for app settings persistence.
abstract class SettingsRepository {
  /// Loads all settings as a map.
  Future<Map<String, dynamic>> loadSettings();

  /// Saves a single boolean setting.
  Future<void> saveBool(String key, bool value);

  /// Reads a single boolean setting.
  Future<bool> getBool(String key, {bool defaultValue = false});

  /// Saves a single string setting.
  Future<void> saveString(String key, String value);

  /// Reads a single string setting.
  Future<String> getString(String key, {String defaultValue = ''});

  /// Clears all settings (used on logout).
  Future<void> clearSettings();
}
