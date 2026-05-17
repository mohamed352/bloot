import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/components/app_button.dart';
import 'package:bloot/core/style/colors.dart';

class RoomInvitationPage extends StatelessWidget {
  const RoomInvitationPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas.withValues(alpha: 0.95),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorManager.darkSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ColorManager.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'room_invitation'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Khalid Al-Rashid',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'invited_you_to_join'.tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorManager.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorManager.darkSectionGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'weekend_bash'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.meeting_room_rounded,
                            size: 16,
                            color: ColorManager.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'private_room'.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: ColorManager.darkTextSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.people_rounded,
                            size: 16,
                            color: ColorManager.primary,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '3/4 players',
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorManager.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'join_room'.tr(),
                  gradient: GradientButton.goldGradient,
                  onPressed: () => context.pushNamed(
                    RouteNames.roomLobby,
                    pathParameters: {'id': id},
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'decline'.tr(),
                  isOutlined: true,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
