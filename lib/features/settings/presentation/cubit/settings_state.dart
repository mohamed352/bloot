import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = SettingsInitial;
  const factory SettingsState.loaded({
    required bool voiceChatEnabled,
    required bool cameraEnabled,
    required bool autoRotateGame,
    required bool soundEffectsEnabled,
    required bool backgroundMusicEnabled,
    required bool showOnlineStatus,
    required String gameSpeed,
    required String speakerMode,
    required String profileVisibility,
  }) = SettingsLoaded;
  const factory SettingsState.error({required String message}) = SettingsError;
}
