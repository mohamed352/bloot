import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/config/firebase_emulator_config.dart';
import 'package:bloot/core/logger/app_logger.dart';

/// Keys for remote-config-backed feature flags and operational values.
abstract class RemoteConfigKeys {
  static const String forceUpdateVersion = 'force_update_version';
  static const String forceUpdateStoreUrl = 'force_update_store_url';
  static const String maintenanceMode = 'maintenance_mode';
  static const String maintenanceMessage = 'maintenance_message';
  static const String minSupportedVersion = 'min_supported_version';
  static const String enableStreaming = 'enable_streaming';
  static const String agoraAppId = 'agora_app_id';
}

/// Admin-managed system settings document in Firestore.
abstract class SystemSettingsKeys {
  static const String maintenanceMode = 'maintenanceMode';
  static const String allowNewSignups = 'allowNewSignups';
  static const String featureFlags = 'featureFlags';
}

/// Reads operational config from Firebase Remote Config and admin-managed
/// Firestore settings. Firestore values take precedence when present, so
/// changes made in the admin dashboard are effective immediately via the
/// real-time listener.
@lazySingleton
class RemoteConfigService {
  RemoteConfigService({
    required FirebaseRemoteConfig remoteConfig,
    required FirebaseFirestore firestore,
  })  : _remoteConfig = remoteConfig,
        _firestore = firestore;

  final FirebaseRemoteConfig _remoteConfig;
  final FirebaseFirestore _firestore;

  Map<String, dynamic>? _systemSettings;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _settingsSubscription;

  static const _defaults = <String, dynamic>{
    RemoteConfigKeys.forceUpdateVersion: '',
    RemoteConfigKeys.forceUpdateStoreUrl: '',
    RemoteConfigKeys.maintenanceMode: false,
    RemoteConfigKeys.maintenanceMessage: '',
    RemoteConfigKeys.minSupportedVersion: '',
    RemoteConfigKeys.enableStreaming: true,
    RemoteConfigKeys.agoraAppId: '',
  };

  /// Initializes Remote Config, fetches the latest values, and starts listening
  /// to admin-managed Firestore settings.
  ///
  /// When running against the Firebase emulator suite, Remote Config fetch is
  /// skipped because there is no Remote Config emulator; defaults are used
  /// instead.
  Future<void> initialize() async {
    try {
      await _remoteConfig.setDefaults(_defaults);
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      if (!FirebaseEmulatorConfig.enabled) {
        await _remoteConfig.fetchAndActivate();
      } else {
        AppLogger.info(
          'Remote Config fetch skipped (emulator mode)',
          tag: LogTags.init,
        );
      }

      await _loadSystemSettings();
      _listenToSystemSettings();
      AppLogger.info('Remote Config initialized', tag: LogTags.init);
    } catch (e) {
      AppLogger.error('Failed to initialize Remote Config', error: e);
    }
  }

  /// Refreshes both Remote Config and admin Firestore settings.
  Future<bool> fetchAndActivate() async {
    try {
      final updated = await _remoteConfig.fetchAndActivate();
      await _loadSystemSettings();
      return updated;
    } catch (e) {
      AppLogger.error('Failed to fetch Remote Config', error: e);
      return false;
    }
  }

  Future<void> _loadSystemSettings() async {
    try {
      final doc = await _firestore.collection('settings').doc('system').get();
      _systemSettings = doc.data();
    } catch (e) {
      AppLogger.error('Failed to load system settings from Firestore', error: e);
      _systemSettings = null;
    }
  }

  void _listenToSystemSettings() {
    _settingsSubscription?.cancel();
    _settingsSubscription = _firestore
        .collection('settings')
        .doc('system')
        .snapshots()
        .listen(
          (snapshot) => _systemSettings = snapshot.data(),
          onError: (Object e) {
            AppLogger.error(
              'System settings real-time stream error',
              error: e,
            );
          },
        );
  }

  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
  int getInt(String key) => _remoteConfig.getInt(key);
  double getDouble(String key) => _remoteConfig.getDouble(key);

  /// Returns parsed JSON or null if the value is empty/invalid.
  Map<String, dynamic>? getJson(String key) {
    final raw = getString(key);
    if (raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to parse Remote Config JSON for $key', error: e);
      return null;
    }
  }

  /// Whether the app is currently in maintenance mode. Admin Firestore settings
  /// override Remote Config so the admin dashboard toggle takes effect.
  bool get isMaintenanceMode {
    final firestoreValue = _systemSettings?[SystemSettingsKeys.maintenanceMode];
    if (firestoreValue is bool) return firestoreValue;
    return getBool(RemoteConfigKeys.maintenanceMode);
  }

  /// Whether new sign-ups are currently allowed.
  bool get allowNewSignups {
    final firestoreValue = _systemSettings?[SystemSettingsKeys.allowNewSignups];
    if (firestoreValue is bool) return firestoreValue;
    return true;
  }

  /// Admin-managed feature flags.
  Map<String, dynamic>? get featureFlags {
    final firestoreValue = _systemSettings?[SystemSettingsKeys.featureFlags];
    if (firestoreValue is Map<String, dynamic>) return firestoreValue;
    return null;
  }

  /// Evaluates a feature flag by checking admin Firestore feature flags first,
  /// then Remote Config for known keys, falling back to [defaultValue].
  bool isFeatureEnabled(String flag, {bool defaultValue = true}) {
    final firestoreFlags = featureFlags;
    if (firestoreFlags != null) {
      final firestoreValue = firestoreFlags[flag];
      if (firestoreValue is bool) return firestoreValue;
    }

    if (flag == RemoteConfigKeys.enableStreaming) {
      return getBool(flag);
    }

    return defaultValue;
  }

  /// Maintenance message to display to users.
  String get maintenanceMessage =>
      getString(RemoteConfigKeys.maintenanceMessage);

  /// Version string that triggers the force-update screen.
  String get forceUpdateVersion =>
      getString(RemoteConfigKeys.forceUpdateVersion);

  /// Store URL opened from the force-update screen.
  String get forceUpdateStoreUrl =>
      getString(RemoteConfigKeys.forceUpdateStoreUrl);

  /// Minimum supported app version.
  String get minSupportedVersion =>
      getString(RemoteConfigKeys.minSupportedVersion);

  /// Whether streaming is enabled.
  bool get enableStreaming =>
      isFeatureEnabled(RemoteConfigKeys.enableStreaming);

  /// Agora App ID. Falls back to the compiled value if not configured.
  String get agoraAppId {
    final remote = getString(RemoteConfigKeys.agoraAppId);
    return remote.isNotEmpty ? remote : '';
  }

  /// Cancels the real-time Firestore settings listener.
  Future<void> dispose() async {
    await _settingsSubscription?.cancel();
    _settingsSubscription = null;
  }
}
