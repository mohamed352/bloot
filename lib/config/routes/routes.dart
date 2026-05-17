abstract class RouteNames {
  // Onboarding & Auth
  static const String splash = 'splash';
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String otp = 'otp';
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
  static const String directMessage = 'directMessage';
  static const String roomInvitation = 'roomInvitation';
  static const String editProfile = 'editProfile';
  static const String userProfile = 'userProfile';
  static const String settings = 'settings';
  static const String privacy = 'privacy';
  static const String terms = 'terms';
  static const String error = 'error';
  static const String offline = 'offline';
}

abstract class RoutePaths {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String otp = '/otp';
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
  static const String directMessage = '/chat/:userId';
  static const String roomInvitation = '/room-invite/:id';
  static const String editProfile = '/edit-profile';
  static const String userProfile = '/user/:userId';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String error = '/error';
  static const String offline = '/offline';
}
