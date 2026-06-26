abstract class RouteNames {
  // Onboarding & Auth
  static const String splash = 'splash';
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String completeProfile = 'completeProfile';

  // Main Shell Tabs
  static const String home = 'home';
  static const String discover = 'discover';
  static const String play = 'play';
  static const String tournamentsTab = 'tournamentsTab';
  static const String chat = 'chat';
  static const String profile = 'profile';

  // Feature Screens
  static const String createRoom = 'createRoom';
  static const String roomLobby = 'roomLobby';
  static const String gamePlay = 'gamePlay';
  static const String watchStream = 'watchStream';
  static const String tournamentDetail = 'tournamentDetail';
  static const String tournamentBracket = 'tournamentBracket';
  static const String tournamentResults = 'tournamentResults';
  static const String directMessage = 'directMessage';
  static const String roomInvitation = 'roomInvitation';
  static const String editProfile = 'editProfile';
  static const String userProfile = 'userProfile';
  static const String settings = 'settings';
  static const String privacy = 'privacy';
  static const String terms = 'terms';
  static const String joinRoom = 'joinRoom';
  static const String notifications = 'notifications';
  static const String newMessage = 'newMessage';
  static const String spectate = 'spectate';
  static const String publicRooms = 'publicRooms';
  static const String forceUpdate = 'forceUpdate';
  static const String maintenance = 'maintenance';
  static const String error = 'error';
  static const String offline = 'offline';
  static const String loading = 'loading';
  static const String success = 'success';

  // Settings Sub-pages
  static const String languageSettings = 'languageSettings';
  static const String notificationSettings = 'notificationSettings';
  static const String privacySettings = 'privacySettings';
  static const String audioSettings = 'audioSettings';
  static const String accountSettings = 'accountSettings';
  static const String aboutSettings = 'aboutSettings';
}

abstract class RoutePaths {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String completeProfile = '/complete-profile';

  static const String home = '/home';
  static const String discover = '/discover';
  static const String play = '/play';
  static const String chat = '/chat';
  static const String profile = '/profile';

  static const String roomLobby = '/room/:id';
  static const String gamePlay = '/game/:id';
  static const String watchStream = '/stream/:id';
  static const String tournamentDetail = '/tournament/:id';
  static const String tournamentBracket = '/tournament/:id/bracket';
  static const String tournamentResults = '/tournament/:id/results';
  static const String directMessage = '/chat/:conversationId';
  static const String roomInvitation = '/room-invite/:id';
  static const String editProfile = '/edit-profile';
  static const String userProfile = '/user/:userId';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String joinRoom = '/join-room';
  static const String notifications = '/notifications';
  static const String newMessage = '/new-message';
  static const String spectate = '/spectate/:id';
  static const String publicRooms = '/public-rooms';
  static const String forceUpdate = '/force-update';
  static const String maintenance = '/maintenance';
  static const String error = '/error';
  static const String offline = '/offline';
  static const String loading = '/loading';
  static const String success = '/success';

  // Settings Sub-pages
  static const String languageSettings = '/settings/language';
  static const String notificationSettings = '/settings/notifications';
  static const String privacySettings = '/settings/privacy';
  static const String audioSettings = '/settings/audio';
  static const String accountSettings = '/settings/account';
  static const String aboutSettings = '/settings/about';
}
