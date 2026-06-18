import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:bloot/features/settings/presentation/cubit/settings_state.dart';

class AudioSettingsPage extends StatelessWidget {
  const AudioSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('audio'.tr()),
        backgroundColor: const Color(0x00000000),
        elevation: 0,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final voiceChat = (state as SettingsLoaded?)?.voiceChatEnabled ?? true;
          final soundEffects = (state as SettingsLoaded?)?.soundEffectsEnabled ?? true;
          final backgroundMusic = (state as SettingsLoaded?)?.backgroundMusicEnabled ?? false;
          final speakerMode = (state as SettingsLoaded?)?.speakerMode ?? 'speaker';

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'voice_chat'.tr(),
                  style: const TextStyle(color: ColorManager.darkTextPrimary),
                ),
                value: voiceChat,
                onChanged: (v) => context.read<SettingsCubit>().toggleVoiceChat(v),
                activeTrackColor: ColorManager.primary,
              ),
              const Divider(color: ColorManager.darkBorderSoft),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'sound_effects'.tr(),
                  style: const TextStyle(color: ColorManager.darkTextPrimary),
                ),
                value: soundEffects,
                onChanged: (v) =>
                    context.read<SettingsCubit>().toggleSoundEffects(v),
                activeTrackColor: ColorManager.primary,
              ),
              const Divider(color: ColorManager.darkBorderSoft),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'background_music'.tr(),
                  style: const TextStyle(color: ColorManager.darkTextPrimary),
                ),
                value: backgroundMusic,
                onChanged: (v) =>
                    context.read<SettingsCubit>().toggleBackgroundMusic(v),
                activeTrackColor: ColorManager.primary,
              ),
              const Divider(color: ColorManager.darkBorderSoft),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'speaker_mode'.tr(),
                  style: const TextStyle(color: ColorManager.darkTextPrimary),
                ),
                subtitle: Text(
                  speakerMode.tr(),
                  style: const TextStyle(color: ColorManager.darkTextSecondary),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: ColorManager.darkTextMuted,
                ),
                onTap: () => _showSpeakerModeSheet(context, speakerMode),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSpeakerModeSheet(BuildContext context, String current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['speaker', 'earpiece'].map((option) {
            return ListTile(
              title: Text(
                option.tr(),
                style: TextStyle(
                  color: option == current
                      ? ColorManager.primary
                      : ColorManager.darkTextPrimary,
                ),
              ),
              trailing: option == current
                  ? const Icon(Icons.check_rounded, color: ColorManager.primary)
                  : null,
              onTap: () {
                context.read<SettingsCubit>().setSpeakerMode(option);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
