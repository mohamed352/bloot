import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/network/cache_keys.dart';
import 'package:bloot/features/settings/domain/repositories/settings_repository.dart';
import 'package:bloot/features/settings/presentation/cubit/settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository,
       super(const SettingsState.initial());

  final SettingsRepository _settingsRepository;

  Future<void> loadSettings() async {
    try {
      final settings = await _settingsRepository.loadSettings();
      emit(
        SettingsState.loaded(
          voiceChatEnabled: settings[CacheKeys.voiceChatEnabled] as bool? ??
              true,
          cameraEnabled: settings[CacheKeys.cameraEnabled] as bool? ?? false,
          autoRotateGame: settings[CacheKeys.autoRotateGame] as bool? ?? true,
          soundEffectsEnabled: settings[CacheKeys.soundEffectsEnabled]
                  as bool? ??
              true,
          backgroundMusicEnabled: settings[CacheKeys.backgroundMusicEnabled]
                  as bool? ??
              false,
          showOnlineStatus: settings[CacheKeys.showOnlineStatus] as bool? ??
              true,
          gameSpeed: settings[CacheKeys.gameSpeedDefault] as String? ?? 'normal',
          speakerMode: settings[CacheKeys.speakerMode] as String? ?? 'speaker',
          profileVisibility: settings[CacheKeys.profileVisibility] as String? ??
              'everyone',
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to load settings', error: e);
      emit(SettingsState.error(message: e.toString()));
    }
  }

  Future<void> toggleVoiceChat(bool value) async {
    await _saveBool(CacheKeys.voiceChatEnabled, value);
  }

  Future<void> toggleCamera(bool value) async {
    await _saveBool(CacheKeys.cameraEnabled, value);
  }

  Future<void> toggleAutoRotate(bool value) async {
    await _saveBool(CacheKeys.autoRotateGame, value);
  }

  Future<void> toggleSoundEffects(bool value) async {
    await _saveBool(CacheKeys.soundEffectsEnabled, value);
  }

  Future<void> toggleBackgroundMusic(bool value) async {
    await _saveBool(CacheKeys.backgroundMusicEnabled, value);
  }

  Future<void> toggleShowOnlineStatus(bool value) async {
    await _saveBool(CacheKeys.showOnlineStatus, value);
  }

  Future<void> setGameSpeed(String value) async {
    await _saveString(CacheKeys.gameSpeedDefault, value);
  }

  Future<void> setSpeakerMode(String value) async {
    await _saveString(CacheKeys.speakerMode, value);
  }

  Future<void> setProfileVisibility(String value) async {
    await _saveString(CacheKeys.profileVisibility, value);
  }

  Future<void> _saveBool(String key, bool value) async {
    try {
      await _settingsRepository.saveBool(key, value);
      state.whenOrNull(
        loaded: (
          voiceChatEnabled,
          cameraEnabled,
          autoRotateGame,
          soundEffectsEnabled,
          backgroundMusicEnabled,
          showOnlineStatus,
          gameSpeed,
          speakerMode,
          profileVisibility,
        ) {
          emit(
            SettingsState.loaded(
              voiceChatEnabled: key == CacheKeys.voiceChatEnabled
                  ? value
                  : voiceChatEnabled,
              cameraEnabled: key == CacheKeys.cameraEnabled
                  ? value
                  : cameraEnabled,
              autoRotateGame: key == CacheKeys.autoRotateGame
                  ? value
                  : autoRotateGame,
              soundEffectsEnabled: key == CacheKeys.soundEffectsEnabled
                  ? value
                  : soundEffectsEnabled,
              backgroundMusicEnabled: key == CacheKeys.backgroundMusicEnabled
                  ? value
                  : backgroundMusicEnabled,
              showOnlineStatus: key == CacheKeys.showOnlineStatus
                  ? value
                  : showOnlineStatus,
              gameSpeed: gameSpeed,
              speakerMode: speakerMode,
              profileVisibility: profileVisibility,
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.error('Failed to save setting $key', error: e);
    }
  }

  Future<void> _saveString(String key, String value) async {
    try {
      await _settingsRepository.saveString(key, value);
      state.whenOrNull(
        loaded: (
          voiceChatEnabled,
          cameraEnabled,
          autoRotateGame,
          soundEffectsEnabled,
          backgroundMusicEnabled,
          showOnlineStatus,
          gameSpeed,
          speakerMode,
          profileVisibility,
        ) {
          emit(
            SettingsState.loaded(
              voiceChatEnabled: voiceChatEnabled,
              cameraEnabled: cameraEnabled,
              autoRotateGame: autoRotateGame,
              soundEffectsEnabled: soundEffectsEnabled,
              backgroundMusicEnabled: backgroundMusicEnabled,
              showOnlineStatus: showOnlineStatus,
              gameSpeed: key == CacheKeys.gameSpeedDefault ? value : gameSpeed,
              speakerMode: key == CacheKeys.speakerMode ? value : speakerMode,
              profileVisibility: key == CacheKeys.profileVisibility
                  ? value
                  : profileVisibility,
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.error('Failed to save setting $key', error: e);
    }
  }

  Future<void> clearSettings() async {
    await _settingsRepository.clearSettings();
  }
}
