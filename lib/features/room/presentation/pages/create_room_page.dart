import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/components/cached_avatar.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/room/domain/entities/room.dart';
import 'package:bloot/generated/locale_keys.g.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';

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
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordValid = false;

  final _roomTypes = [
    _RoomTypeData(
      'private'.tr(),
      Icons.lock_rounded,
      'invite_only'.tr(),
      ColorManager.primary,
    ),
    _RoomTypeData(
      'public'.tr(),
      Icons.public_rounded,
      'anyone_can_join'.tr(),
      ColorManager.info,
    ),
    _RoomTypeData(
      'live_stream'.tr(),
      Icons.live_tv_rounded,
      'broadcast_to_viewers'.tr(),
      ColorManager.live,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFormChanged);
    _passwordController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (_selectedType == 0) {
      final password = _passwordController.text.trim();
      final isValid = password.isNotEmpty && password.length >= 4;
      if (isValid != _isPasswordValid) {
        setState(() => _isPasswordValid = isValid);
      }
    } else if (!_isPasswordValid) {
      setState(() => _isPasswordValid = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomCubit, RoomState>(
      listener: (context, state) {
        state.whenOrNull(
          created: (room) => context.pushNamed(
            RouteNames.roomLobby,
            pathParameters: {'id': room.id},
          ),
          error: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
        );
      },
      builder: (context, state) {
        final isLoading = state is RoomLoading;
        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          appBar: AppBar(
            title: Text('create_room'.tr()),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room name
                  _buildLabel('room_name'.tr()),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      color: ColorManager.darkTextPrimary,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'room_name'.tr(),
                      filled: true,
                      fillColor: ColorManager.darkSectionGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.cardCompact),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.cardCompact),
                        borderSide: const BorderSide(
                          color: ColorManager.darkBorderSoft,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.cardCompact),
                        borderSide: const BorderSide(
                          color: ColorManager.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Room type with radio buttons
                  _buildLabel('room_type'.tr()),
                  const SizedBox(height: AppSpacing.md),
                  Column(
                    children: _roomTypes.asMap().entries.map((e) {
                      final isSelected = e.key == _selectedType;
                      final isLiveStream = e.key == 2;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = e.key;
                            _onFormChanged();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? e.value.color.withValues(alpha: 0.1)
                                : ColorManager.darkSurface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
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
                                  borderRadius: BorderRadius.circular(AppRadius.iconContainer),
                                ),
                                child: Icon(
                                  e.value.icon,
                                  color: isSelected
                                      ? e.value.color
                                      : ColorManager.darkTextMuted,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
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
                                          const SizedBox(width: AppSpacing.sm),
                                          Container(
                                            padding:
                                                const EdgeInsetsDirectional.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                            decoration: BoxDecoration(
                                              color: ColorManager.live
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(AppRadius.xs),
                                            ),
                                            child: Text(
                                              LocaleKeys.liveBadge.tr(),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: ColorManager.live,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xxs),
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
                  const SizedBox(height: AppSpacing.xxl),
                  // Toggles
                  _buildToggle(
                    'voice_chat'.tr(),
                    _voiceOn,
                    (v) => setState(() => _voiceOn = v),
                  ),
                  _buildToggle(
                    'camera'.tr(),
                    _cameraOn,
                    (v) => setState(() => _cameraOn = v),
                  ),
                  _buildToggle(
                    'allow_spectators'.tr(),
                    _spectatorsOn,
                    (v) => setState(() => _spectatorsOn = v),
                  ),
                  // Password for private rooms
                  if (_selectedType == 0) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    _buildLabel('room_password'.tr()),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(
                        color: ColorManager.darkTextPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'enter_password'.tr(),
                        errorText: _isPasswordValid
                            ? null
                            : 'password_min_length'.tr(),
                        filled: true,
                        fillColor: ColorManager.darkSectionGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.cardCompact),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.cardCompact),
                          borderSide: const BorderSide(
                            color: ColorManager.darkBorderSoft,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.cardCompact),
                          borderSide: const BorderSide(
                            color: ColorManager.primary,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.cardCompact),
                          borderSide: const BorderSide(
                            color: ColorManager.error,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.cardCompact),
                          borderSide: const BorderSide(
                            color: ColorManager.error,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'private_room_password_required'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorManager.darkTextMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  // Lobby Preview with player avatars in a row
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: ColorManager.darkSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
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
                                color: _roomTypes[_selectedType].color
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              child: Icon(
                                _roomTypes[_selectedType].icon,
                                color: _roomTypes[_selectedType].color,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
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
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    '${_roomTypes[_selectedType].name} • ${LocaleKeys.playersCount.tr(namedArgs: {'current': '0', 'max': '4'})}',
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
                        const SizedBox(height: AppSpacing.md),
                        // Lobby Preview: player avatars in a row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPreviewAvatar(
                              null,
                              true,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _buildPreviewAvatar(null, false),
                            const SizedBox(width: AppSpacing.sm),
                            _buildPreviewAvatar(null, false),
                            const SizedBox(width: AppSpacing.sm),
                            _buildPreviewAvatar(null, false),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildChip(
                              Icons.mic_rounded,
                              _voiceOn ? LocaleKeys.labelOn.tr() : 'off'.tr(),
                              _voiceOn,
                            ),
                            _buildChip(
                              Icons.videocam_rounded,
                              _cameraOn ? LocaleKeys.labelOn.tr() : 'off'.tr(),
                              _cameraOn,
                            ),
                            _buildChip(
                              Icons.visibility_rounded,
                              _spectatorsOn
                                  ? LocaleKeys.labelOn.tr()
                                  : 'off'.tr(),
                              _spectatorsOn,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Cancel text button
                  Center(
                    child: TextButton(
                      onPressed: () => context.goNamed(RouteNames.home),
                      child: Text(
                        'cancel'.tr(),
                        style: const TextStyle(
                          color: ColorManager.darkTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Create Room button with gold gradient and + icon
                  GradientButton(
                    text: 'create_room'.tr(),
                    gradient: GradientButton.goldGradient,
                    icon: Icons.add_rounded,
                    isLoading: isLoading,
                    onPressed: isLoading || (_selectedType == 0 && !_isPasswordValid)
                        ? null
                        : () {
                            final name = _nameController.text.trim();
                            if (_selectedType == 0 &&
                                _passwordController.text.trim().length < 4) {
                              setState(() => _isPasswordValid = false);
                              return;
                            }
                            context.read<RoomCubit>().createRoom(
                              CreateRoomParams(
                                name: name.isNotEmpty ? name : 'room'.tr(),
                                type: RoomType.values[_selectedType],
                                voiceEnabled: _voiceOn,
                                cameraEnabled: _cameraOn,
                                allowSpectators: _spectatorsOn,
                                password: _selectedType == 0
                                    ? _passwordController.text.trim()
                                    : null,
                              ),
                            );
                          },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewAvatar(String? imageUrl, bool isFilled) {
    return CachedAvatar(
      imageUrl: imageUrl,
      size: 40,
      borderColor: isFilled
          ? ColorManager.primary
          : ColorManager.darkBorderSoft,
      borderWidth: 2,
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
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
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

  Widget _buildChip(IconData icon, String label, bool active) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: active
            ? ColorManager.primary.withValues(alpha: 0.15)
            : ColorManager.darkSectionGray,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: active ? ColorManager.primary : ColorManager.darkTextMuted,
          ),
          const SizedBox(width: AppSpacing.xs),
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
