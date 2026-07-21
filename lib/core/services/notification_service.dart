import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';

@lazySingleton
class NotificationService {
  NotificationService({
    required FirebaseMessaging messaging,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _messaging = messaging,
        _firestore = firestore,
        _auth = auth;

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  final StreamController<RemoteMessage> _onMessageController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _onMessageOpenedAppController =
      StreamController<RemoteMessage>.broadcast();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  bool _initialized = false;

  Stream<RemoteMessage> get onMessage => _onMessageController.stream;
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _onMessageOpenedAppController.stream;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Request permissions
    await requestPermission();

    // iOS: show notifications as banners/sound/badge while app is in foreground.
    // Without this, foreground FCM notifications are silently swallowed on iOS.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get and save token.
    try {
      final token = await getToken();
      if (token != null) {
        await _saveToken(token);
      }
    } catch (e) {
      AppLogger.warning('Failed to get FCM token (common on iOS Simulator): $e', tag: 'FCM');
    }

    // Listen to token refresh
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(_saveToken);

    // Foreground messages
    await _onMessageSubscription?.cancel();
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((message) {
      AppLogger.info(
        'FCM foreground: ${message.notification?.title}',
        tag: 'FCM',
      );
      _onMessageController.add(message);
    });

    // Background/terminated tap
    await _onMessageOpenedAppSubscription?.cancel();
    _onMessageOpenedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      AppLogger.info(
        'FCM opened app: ${message.notification?.title}',
        tag: 'FCM',
      );
      _onMessageOpenedAppController.add(message);
    });

    // Check if app was opened from terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedAppController.add(initialMessage);
    }
  }

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission();
    AppLogger.info(
      'FCM permission: ${settings.authorizationStatus}',
      tag: 'FCM',
    );
  }

  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  /// Persists the device's current language to the user document so that
  /// server-side push notifications can be localized for the recipient.
  Future<void> syncLocale(String languageCode) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'locale': languageCode,
      });
    } catch (e) {
      AppLogger.error('Failed to sync locale', error: e, tag: 'FCM');
    }
  }

  Future<void> _saveToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('FCM token saved', tag: 'FCM');
    } catch (e) {
      AppLogger.error('Failed to save FCM token', error: e, tag: 'FCM');
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _onMessageSubscription?.cancel();
    await _onMessageOpenedAppSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _onMessageSubscription = null;
    _onMessageOpenedAppSubscription = null;
    await _onMessageController.close();
    await _onMessageOpenedAppController.close();
  }
}
