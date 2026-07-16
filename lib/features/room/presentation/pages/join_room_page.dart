import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/components/app_scaffold.dart';
import 'package:bloot/core/components/custom_app_bar.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/extension/context_values.dart';
import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/cubit/room_state.dart';
import 'package:bloot/generated/locale_keys.g.dart';

/// Screen for joining an existing room via a 6-character invite code.
class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isValid = false;
  bool _passwordRequired = false;
  bool _isCheckingPasswordRequirement = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
    _passwordController.addListener(_onPasswordChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onCodeChanged();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    final code = _codeController.text.trim().toUpperCase();
    final isValid = code.length == 6;
    if (isValid != _isValid) {
      setState(() => _isValid = isValid);
    }
    if (code.length == 6) {
      _checkPasswordRequirement(code);
    } else if (_passwordRequired) {
      setState(() => _passwordRequired = false);
    }
  }

  void _onPasswordChanged() {
    // Re-evaluate the join button state when password changes.
    setState(() {});
  }

  Future<void> _checkPasswordRequirement(String code) async {
    if (_isCheckingPasswordRequirement) return;
    setState(() => _isCheckingPasswordRequirement = true);
    final required = await context.read<RoomCubit>().isPasswordRequired(code);
    if (mounted) {
      setState(() {
        _passwordRequired = required;
        _isCheckingPasswordRequirement = false;
      });
    }
  }

  bool get _canJoin {
    if (!_isValid) return false;
    if (_passwordRequired && _passwordController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void _joinRoom() {
    AppLogger.info('Join Room button pressed', tag: 'JoinRoom');
    final code = _codeController.text.trim().toUpperCase();
    AppLogger.info('Code: $code, canJoin: $_canJoin', tag: 'JoinRoom');
    if (!_canJoin) return;
    context.read<RoomCubit>().joinRoomByCode(
      code,
      password: _passwordController.text.trim(),
    );
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      final pasted = data!.text!.trim().toUpperCase();
      final code = pasted.length > 6 ? pasted.substring(0, 6) : pasted;
      _codeController.text = code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppScaffold(
      appBar: CustomAppBar(title: LocaleKeys.join_room.tr()),
      body: BlocConsumer<RoomCubit, RoomState>(
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
          return SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  LocaleKeys.room_code.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  enabled: !isLoading,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ABC123',
                    hintStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 8,
                      color: colors.textPlaceholder,
                    ),
                    counterText: '',
                    filled: true,
                    fillColor: colors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 24),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: TextButton.icon(
                    onPressed: isLoading ? null : _pasteFromClipboard,
                    icon: Icon(Icons.paste_rounded, color: colors.primary),
                    label: Text(
                      LocaleKeys.pasteFromClipboard.tr(),
                      style: TextStyle(color: colors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                // Password (only shown for private rooms that require one)
                if (_passwordRequired) ...[
                  Row(
                    children: [
                      Text(
                        'room_password'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                      if (_isCheckingPasswordRequirement) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    enabled: !isLoading,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'enter_password'.tr(),
                      hintStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colors.textPlaceholder,
                      ),
                      filled: true,
                      fillColor: colors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    LocaleKeys.password_required_for_locked_room.tr(),
                    style: TextStyle(fontSize: 12, color: colors.error),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ] else if (_isCheckingPasswordRequirement) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxxl),
                AppButton(
                  text: LocaleKeys.join_room.tr(),
                  isLoading: isLoading,
                  onPressed: _canJoin && !isLoading ? _joinRoom : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
