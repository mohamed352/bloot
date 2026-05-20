import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/app_redirect.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:bloot/features/auth/presentation/pages/login_page.dart';
import 'package:bloot/features/auth/presentation/pages/otp_page.dart';
import 'package:bloot/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:bloot/features/chat/presentation/pages/chat_list_page.dart';
import 'package:bloot/features/chat/presentation/pages/direct_message_page.dart';
import 'package:bloot/features/chat/presentation/pages/room_invitation_page.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/pages/discover_streams_page.dart';
import 'package:bloot/features/discover/presentation/pages/watch_stream_page.dart';
import 'package:bloot/features/chat/presentation/pages/new_message_page.dart';
import 'package:bloot/features/chat/presentation/pages/notifications_page.dart';
import 'package:bloot/features/edge_cases/presentation/pages/error_page.dart';
import 'package:bloot/features/edge_cases/presentation/pages/force_update_page.dart';
import 'package:bloot/features/edge_cases/presentation/pages/maintenance_page.dart';
import 'package:bloot/features/edge_cases/presentation/pages/offline_page.dart';
import 'package:bloot/features/game/presentation/cubit/game_cubit.dart';
import 'package:bloot/features/game/presentation/pages/game_play_page.dart';
import 'package:bloot/features/home/presentation/pages/home_page.dart';
import 'package:bloot/features/onboarding/presentation/pages/splash_page.dart';
import 'package:bloot/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:bloot/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:bloot/features/profile/presentation/pages/user_profile_page.dart';
import 'package:bloot/features/room/presentation/pages/create_room_page.dart';
import 'package:bloot/features/room/presentation/pages/join_room_page.dart';
import 'package:bloot/features/room/presentation/pages/room_lobby_page.dart';
import 'package:bloot/features/settings/presentation/pages/privacy_policy_page.dart';
import 'package:bloot/features/settings/presentation/pages/settings_page.dart';
import 'package:bloot/features/settings/presentation/pages/terms_page.dart';
import 'package:bloot/features/shell/presentation/widgets/main_shell_widget.dart';
import 'package:bloot/features/tournament/presentation/cubit/tournament_cubit.dart';
import 'package:bloot/features/tournament/presentation/pages/tournament_detail_page.dart';
import 'package:bloot/features/tournament/presentation/pages/tournament_list_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: true,
  redirect: AppRedirect.globalRedirect,
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
      path: RoutePaths.otp,
      name: RouteNames.otp,
      builder: (context, state) => const OtpPage(),
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
              builder: (context, state) => const HomePage(),
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
              builder: (context, state) => const CreateRoomPage(),
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
              builder: (context, state) => const UserProfilePage(),
            ),
          ],
        ),
      ],
    ),

    // Feature Screens (outside shell)
    GoRoute(
      path: '/tournaments',
      name: RouteNames.tournamentsTab,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<TournamentCubit>()..loadTournaments(),
        child: const TournamentListPage(),
      ),
    ),
    GoRoute(
      path: RoutePaths.roomLobby,
      name: RouteNames.roomLobby,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RoomLobbyPage(id: id);
      },
    ),
    GoRoute(
      path: RoutePaths.gamePlay,
      name: RouteNames.gamePlay,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<GameCubit>()..loadGame(id),
          child: GamePlayPage(id: id),
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
      path: RoutePaths.tournamentDetail,
      name: RouteNames.tournamentDetail,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TournamentDetailPage(id: id);
      },
    ),
    GoRoute(
      path: RoutePaths.directMessage,
      name: RouteNames.directMessage,
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return BlocProvider(
          create: (_) => getIt<ChatCubit>()..loadMessages(userId),
          child: DirectMessagePage(userId: userId),
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
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: RoutePaths.userProfile,
      name: RouteNames.userProfile,
      builder: (context, state) {
        return const UserProfilePage();
      },
    ),
    GoRoute(
      path: RoutePaths.settings,
      name: RouteNames.settings,
      builder: (context, state) => const SettingsPage(),
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
      path: RoutePaths.error,
      name: RouteNames.error,
      builder: (context, state) => const ErrorPage(),
    ),
    GoRoute(
      path: RoutePaths.joinRoom,
      name: RouteNames.joinRoom,
      builder: (context, state) => const JoinRoomPage(),
    ),
    GoRoute(
      path: RoutePaths.notifications,
      name: RouteNames.notifications,
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: RoutePaths.newMessage,
      name: RouteNames.newMessage,
      builder: (context, state) => const NewMessagePage(),
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
  ],
);
