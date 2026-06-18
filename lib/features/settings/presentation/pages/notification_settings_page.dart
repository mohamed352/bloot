import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late SharedPreferences _prefs;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() => _loaded = true);
  }

  bool _get(String key) => _prefs.getBool(key) ?? true;

  Future<void> _set(String key, bool value) async {
    await _prefs.setBool(key, value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('notifications'.tr()),
        backgroundColor: const Color(0x00000000),
        elevation: 0,
      ),
      body: _loaded
          ? ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _buildToggle('Room Invites', 'notif_room_invites'),
                _buildToggle('Game Starts', 'notif_game_starts'),
                _buildToggle('Tournaments', 'notif_tournaments'),
                _buildToggle('Messages', 'notif_messages'),
                _buildToggle('Streams', 'notif_streams'),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: ColorManager.primary),
            ),
    );
  }

  Widget _buildToggle(String title, String key) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(color: ColorManager.darkTextPrimary),
      ),
      value: _get(key),
      onChanged: (v) => _set(key, v),
      activeTrackColor: ColorManager.primary,
    );
  }
}
