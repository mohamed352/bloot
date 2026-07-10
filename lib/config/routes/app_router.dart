import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/app_redirect.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_state.dart';
import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:bloot/features/auth/presentation/pages/login_page.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:bloot/features/chat/presentation/cubit/new_message_cubit.dart';
import 'package:bloot/features/chat/domain/entities/chat.dart';
import 'package:bloot/features/chat/presentation/pages/chat_list_page.dart';
import 'package:bloot/features/chat/presentation/pages/direct_message_page.dart';
import 'package:bloot/features/chat/presentation/pages/room_invitation_page.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/pages/discover_streams_page.dart';
import 'package:bloot/features/discover/presentation/pages/watch_stream_page.dart';
import 'package:bloot/features/chat/presentation/pages/new_message_page.dart';
import 'package:bloot/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:bloot/features/notifications/presentation/pages/notifications_page.dart';
import 'package:bloot/features/edge_cases/presentation/pages/error_page.dart';
import 'package:bloot/features/edge_cases/presentation/pages/force_update_page.dart';
import 'package:bloot/features/edge_cases/presentation/pages/loading_page.dart';
import 'package:bloot/features/edge_cases/presentation/pages/maintenance_page.dart';
import 'package:bloot/features/edge_cases/presentation/pages/offline_page.dart';
import 'package:bloot/features/edge_cases/presentation/pages/success_page.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/pages/html_game_play_page.dart';
import 'package:bloot/features/home/presentation/cubit/home_cubit.dart';
import 'package:bloot/features/home/presentation/pages/home_page.dart';
import 'package:bloot/features/onboarding/presentation/pages/splash_page.dart';
import 'package:bloot/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';
import 'package:bloot/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:bloot/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bloot/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:bloot/features/profile/presentation/pages/user_profile_page.dart';
import 'package:bloot/features/room/presentation/cubit/room_cubit.dart';
import 'package:bloot/features/room/presentation/pages/create_room_page.dart';
import 'package:bloot/features/room/presentation/pages/join_room_page.dart';
import 'package:bloot/features/room/presentation/pages/public_rooms_page.dart';
import 'package:bloot/features/room/presentation/pages/room_lobby_page.dart';
import 'package:bloot/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:bloot/features/settings/presentation/pages/about_settings_page.dart';
import 'package:bloot/features/settings/presentation/pages/account_settings_page.dart';
import 'package:bloot/features/settings/presentation/pages/audio_settings_page.dart';
import 'package:bloot/features/settings/presentation/pages/language_settings_page.dart';
import 'package:bloot/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:bloot/features/settings/presentation/pages/privacy_policy_page.dart';
import 'package:bloot/features/settings/presentation/pages/privacy_settings_page.dart';
import 'package:bloot/features/settings/presentation/pages/settings_page.dart';
import 'package:bloot/features/settings/presentation/pages/terms_page.dart';
import 'package:bloot/features/shell/presentation/widgets/main_shell_widget.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: true,
  redirect: AppRedirect.globalRedirect,
  refreshListenable: _AuthCubitRefresh(getIt<AuthCubit>().stream),
  routes: [
    // Onboarding & Auth (outside shell)
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RoutePaths.welcome,
      name: RouteNames.welcome,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RoutePaths.completeProfile,
      name: RouteNames.completeProfile,
      builder: (context, state) => const CompleteProfilePage(),
    ),

    // Main Shell with Bottom Navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellWidget(navigationShell: navigationShell);
      },
      branches: [
        // Home Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.home,
              name: RouteNames.home,
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<HomeCubit>()..loadHomeData(),
                child: const HomePage(),
              ),
            ),
          ],
        ),
        // Discover Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.discover,
              name: RouteNames.discover,
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<DiscoverCubit>()..loadStreams(),
                child: const DiscoverStreamsPage(),
              ),
            ),
          ],
        ),
        // Play Tab (Create Room)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.play,
              name: RouteNames.play,
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<RoomCubit>(),
                child: const CreateRoomPage(),
              ),
            ),
          ],
        ),
        // Chat Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.chat,
              name: RouteNames.chat,
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<ChatCubit>()..loadConversations(),
                child: const ChatListPage(),
              ),
            ),
          ],
        ),
        // Profile Tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.profile,
              name: RouteNames.profile,
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<ProfileCubit>()..loadProfile('me'),
                child: const UserProfilePage(userId: 'me'),
              ),
            ),
          ],
        ),
      ],
    ),

    // Feature Screens (outside shell)
    GoRoute(
      path: RoutePaths.roomLobby,
      name: RouteNames.roomLobby,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<RoomCubit>()..loadRoom(id),
          child: RoomLobbyPage(id: id),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.gamePlay,
      name: RouteNames.gamePlay,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<GameCubit>()..loadGame(id),
          child: HtmlGamePlayPage(id: id),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.gameSim,
      name: RouteNames.gameSim,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<GameCubit>()..loadGame('sim_1'),
          child: const HtmlGamePlayPage(id: 'sim_1'),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.watchStream,
      name: RouteNames.watchStream,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<DiscoverCubit>()..loadStream(id),
          child: WatchStreamPage(id: id),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.directMessage,
      name: RouteNames.directMessage,
      builder: (context, state) {
        final conversationId = state.pathParameters['conversationId']!;
        final conversation = state.extra as ChatConversation?;
        return BlocProvider(
          create: (_) => getIt<ChatCubit>()..watchMessages(conversationId),
          child: DirectMessagePage(
            conversationId: conversationId,
            conversation: conversation,
          ),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.roomInvitation,
      name: RouteNames.roomInvitation,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RoomInvitationPage(id: id);
      },
    ),
    GoRoute(
      path: RoutePaths.editProfile,
      name: RouteNames.editProfile,
      builder: (context, state) {
        final profile = state.extra as UserProfile?;
        final cubit = getIt<EditProfileCubit>();
        if (profile != null) {
          cubit.loadProfile(profile);
        } else {
          // Deep-link / direct open: load current user profile from repository.
          cubit.loadCurrentUserProfile();
        }
        return BlocProvider(
          create: (_) => cubit,
          child: const EditProfilePage(),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.userProfile,
      name: RouteNames.userProfile,
      builder: (context, state) {
        final userId = state.pathParameters['userId'] ?? 'me';
        return BlocProvider(
          create: (_) => getIt<ProfileCubit>()..loadProfile(userId),
          child: UserProfilePage(userId: userId),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.settings,
      name: RouteNames.settings,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<SettingsCubit>()..loadSettings(),
        child: const SettingsPage(),
      ),
    ),
    GoRoute(
      path: RoutePaths.privacy,
      name: RouteNames.privacy,
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: RoutePaths.terms,
      name: RouteNames.terms,
      builder: (context, state) => const TermsPage(),
    ),
    GoRoute(
      path: RoutePaths.languageSettings,
      name: RouteNames.languageSettings,
      builder: (context, state) => const LanguageSettingsPage(),
    ),
    GoRoute(
      path: RoutePaths.notificationSettings,
      name: RouteNames.notificationSettings,
      builder: (context, state) => const NotificationSettingsPage(),
    ),
    GoRoute(
      path: RoutePaths.privacySettings,
      name: RouteNames.privacySettings,
      builder: (context, state) => const PrivacySettingsPage(),
    ),
    GoRoute(
      path: RoutePaths.audioSettings,
      name: RouteNames.audioSettings,
      builder: (context, state) => const AudioSettingsPage(),
    ),
    GoRoute(
      path: RoutePaths.accountSettings,
      name: RouteNames.accountSettings,
      builder: (context, state) => const AccountSettingsPage(),
    ),
    GoRoute(
      path: RoutePaths.aboutSettings,
      name: RouteNames.aboutSettings,
      builder: (context, state) => const AboutSettingsPage(),
    ),
    GoRoute(
      path: RoutePaths.error,
      name: RouteNames.error,
      builder: (context, state) => const ErrorPage(),
    ),
    GoRoute(
      path: RoutePaths.joinRoom,
      name: RouteNames.joinRoom,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<RoomCubit>(),
        child: const JoinRoomPage(),
      ),
    ),
    GoRoute(
      path: RoutePaths.spectate,
      name: RouteNames.spectate,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<GameCubit>()..watchGameAsSpectator(id),
          child: HtmlGamePlayPage(id: id, isSpectator: true),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.publicRooms,
      name: RouteNames.publicRooms,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<RoomCubit>(),
        child: const PublicRoomsPage(),
      ),
    ),
    GoRoute(
      path: RoutePaths.notifications,
      name: RouteNames.notifications,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<NotificationsCubit>()..loadNotifications(),
        child: const NotificationsPage(),
      ),
    ),
    GoRoute(
      path: RoutePaths.newMessage,
      name: RouteNames.newMessage,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<NewMessageCubit>(),
        child: const NewMessagePage(),
      ),
    ),
    GoRoute(
      path: RoutePaths.forceUpdate,
      name: RouteNames.forceUpdate,
      builder: (context, state) => const ForceUpdatePage(),
    ),
    GoRoute(
      path: RoutePaths.maintenance,
      name: RouteNames.maintenance,
      builder: (context, state) => const MaintenancePage(),
    ),
    GoRoute(
      path: RoutePaths.offline,
      name: RouteNames.offline,
      builder: (context, state) => const OfflinePage(),
    ),
    GoRoute(
      path: RoutePaths.loading,
      name: RouteNames.loading,
      builder: (context, state) {
        final message = state.extra as String?;
        return LoadingPage(message: message);
      },
    ),
    GoRoute(
      path: RoutePaths.success,
      name: RouteNames.success,
      builder: (context, state) {
        final message = state.extra as String?;
        return SuccessPage(message: message);
      },
    ),
  ],
);

/// Notifies [GoRouter] whenever the [AuthCubit] state changes so that the
/// global redirect guard is re-evaluated.
class _AuthCubitRefresh extends ChangeNotifier {
  _AuthCubitRefresh(Stream<AuthState> stream) {
    // Cancel any previous instance's subscription to avoid leaking listeners
    // if the router is recreated in tests or long-lived scenarios.
    _activeSubscription?.cancel();
    _activeSubscription = stream.listen((_) => notifyListeners());
  }

  static StreamSubscription<AuthState>? _activeSubscription;

  @override
  void dispose() {
    _activeSubscription?.cancel();
    _activeSubscription = null;
    super.dispose();
  }
}
