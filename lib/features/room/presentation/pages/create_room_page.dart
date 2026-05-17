import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  int _selectedType = 0;
  bool _voiceOn = true;
  bool _cameraOn = false;
  bool _spectatorsOn = true;
  bool _showAdvanced = false;
  int _selectedSpeed = 1; // 0=Relaxed, 1=Normal, 2=Fast
  final _nameController = TextEditingController(text: 'ahmeds_room'.tr());

  final _roomTypes = [
    _RoomTypeData('private'.tr(), Icons.lock_rounded, 'invite_only'.tr(), ColorManager.primary),
    _RoomTypeData('public'.tr(), Icons.public_rounded, 'anyone_can_join'.tr(), ColorManager.info),
    _RoomTypeData('live_stream'.tr(), Icons.live_tv_rounded, 'broadcast_to_viewers'.tr(), ColorManager.live),
  ];

  final _speedOptions = ['relaxed'.tr(), 'normal'.tr(), 'fast'.tr()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      appBar: AppBar(
        title: Text('create_room'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room name
              _buildLabel('room_name'.tr()),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(
                  color: ColorManager.darkTextPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ColorManager.darkSectionGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: ColorManager.darkBorderSoft,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: ColorManager.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Room type with radio buttons
              _buildLabel('room_type'.tr()),
              const SizedBox(height: 12),
              Column(
                children: _roomTypes.asMap().entries.map((e) {
                  final isSelected = e.key == _selectedType;
                  final isLiveStream = e.key == 2;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = e.key),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? e.value.color.withValues(alpha: 0.1)
                            : ColorManager.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? e.value.color.withValues(alpha: 0.5)
                              : ColorManager.darkBorderSoft,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: e.value.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              e.value.icon,
                              color: isSelected ? e.value.color : ColorManager.darkTextMuted,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      e.value.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? e.value.color
                                            : ColorManager.darkTextPrimary,
                                      ),
                                    ),
                                    if (isLiveStream) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsetsDirectional.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorManager.live.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'LIVE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: ColorManager.live,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  e.value.desc,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ColorManager.darkTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Radio button indicator
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? e.value.color
                                    : ColorManager.darkBorderSoft,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: e.value.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Toggles
              _buildToggle('voice_chat'.tr(), _voiceOn, (v) => setState(() => _voiceOn = v)),
              _buildToggle('camera'.tr(), _cameraOn, (v) => setState(() => _cameraOn = v)),
              _buildToggle('allow_spectators'.tr(), _spectatorsOn, (v) => setState(() => _spectatorsOn = v)),
              const SizedBox(height: 16),
              // Advanced settings
              GestureDetector(
                onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                child: Row(
                  children: [
                    Text(
                      'advanced_settings'.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.darkTextPrimary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _showAdvanced
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: ColorManager.darkTextMuted,
                    ),
                  ],
                ),
              ),
              if (_showAdvanced) ...[
                const SizedBox(height: 12),
                _buildDropdown('minimum_level'.tr(), 'level_1'.tr()),
                const SizedBox(height: 12),
                // Game Speed segmented buttons
                _buildLabel('game_speed'.tr()),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: ColorManager.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorManager.darkBorderSoft,
                    ),
                  ),
                  child: Row(
                    children: _speedOptions.asMap().entries.map((e) {
                      final isSelected = e.key == _selectedSpeed;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSpeed = e.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ColorManager.primary.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: ColorManager.primary.withValues(alpha: 0.5),
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? ColorManager.primary
                                      : ColorManager.darkTextSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                _buildDropdown('room_password'.tr(), 'none'.tr()),
              ],
              const SizedBox(height: 24),
              // Lobby Preview with player avatars in a row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorManager.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColorManager.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _roomTypes[_selectedType].color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _roomTypes[_selectedType].icon,
                            color: _roomTypes[_selectedType].color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameController.text,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.darkTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_roomTypes[_selectedType].name} • 0/4 players',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: ColorManager.darkTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Lobby Preview: player avatars in a row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPreviewAvatar('https://i.pravatar.cc/150?img=11', true),
                        const SizedBox(width: 8),
                        _buildPreviewAvatar(null, false),
                        const SizedBox(width: 8),
                        _buildPreviewAvatar(null, false),
                        const SizedBox(width: 8),
                        _buildPreviewAvatar(null, false),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildChip(Icons.mic_rounded, _voiceOn ? 'on'.tr() : 'off'.tr(), _voiceOn),
                        _buildChip(Icons.videocam_rounded, _cameraOn ? 'on'.tr() : 'off'.tr(), _cameraOn),
                        _buildChip(Icons.visibility_rounded, _spectatorsOn ? 'on'.tr() : 'off'.tr(), _spectatorsOn),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Cancel text button
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'cancel'.tr(),
                    style: const TextStyle(
                      color: ColorManager.darkTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Create Room button with gold gradient and + icon
              GradientButton(
                text: 'create_room'.tr(),
                gradient: GradientButton.goldGradient,
                icon: Icons.add_rounded,
                onPressed: () => context.pushNamed(
                  RouteNames.roomLobby,
                  pathParameters: {'id': 'room_new'},
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewAvatar(String? imageUrl, bool isFilled) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? null : ColorManager.darkSectionGray,
        border: Border.all(
          color: isFilled ? ColorManager.primary : ColorManager.darkBorderSoft,
          width: 2,
        ),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? const Icon(
              Icons.person_outline_rounded,
              size: 20,
              color: ColorManager.darkTextMuted,
            )
          : null,
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ColorManager.darkTextPrimary,
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: ColorManager.darkTextPrimary,
            ),
          ),
          const Spacer(),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: ColorManager.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ColorManager.darkSectionGray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorManager.darkBorderSoft,
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: ColorManager.darkTextPrimary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorManager.primary,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ColorManager.darkTextMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, bool active) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? ColorManager.primary.withValues(alpha: 0.15)
            : ColorManager.darkSectionGray,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: active ? ColorManager.primary : ColorManager.darkTextMuted,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? ColorManager.primary : ColorManager.darkTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomTypeData {
  _RoomTypeData(this.name, this.icon, this.desc, this.color);
  final String name;
  final IconData icon;
  final String desc;
  final Color color;
}
