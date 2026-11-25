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

  /// Holds the notification that cold-started the app until a listener is
  /// ready. [initialize] runs before `runApp`, so pushing this into the
  /// broadcast stream would drop it (no subscribers yet) and an invite tap
  /// on a killed app would do nothing.
  RemoteMessage? _pendingInitialMessage;

  Stream<RemoteMessage> get onMessage => _onMessageController.stream;
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _onMessageOpenedAppController.stream;

  /// Returns the notification that launched the app from a terminated state,
  /// exactly once. Call after subscribing to [onMessageOpenedApp].
  RemoteMessage? takeInitialMessage() {
    final message = _pendingInitialMessage;
    _pendingInitialMessage = null;
    return message;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // NOTE: the notification permission request is intentionally NOT done
    // here. initialize() runs before runApp(), and the Android 13+ system
    // permission dialog would pop over the blank native splash before any
    // app UI exists. BlootApp requests it after the first frame instead.

    // iOS: show notifications as banners/sound/badge while app is in foreground.
    // Without this, foreground FCM notifications are silently swallowed on iOS.
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      AppLogger.warning(
        'Failed to set foreground presentation options: $e',
        tag: 'FCM',
      );
    }

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

    // Check if app was opened from terminated state via notification.
    // Buffer it (instead of emitting) because subscribers only attach after
    // runApp; a broadcast stream would silently drop this event.
    try {
      _pendingInitialMessage = await _messaging.getInitialMessage();
    } catch (e) {
      AppLogger.warning('Failed to get initial FCM message: $e', tag: 'FCM');
    }
  }

  Future<void> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission();
      AppLogger.info(
        'FCM permission: ${settings.authorizationStatus}',
        tag: 'FCM',
      );
    } catch (e) {
      AppLogger.warning('Failed to request FCM permission: $e', tag: 'FCM');
    }
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
      final userDoc = _firestore.collection('users').doc(user.uid);
      // Legacy single-token field kept for backward compatibility with older
      // app versions and any server code that still reads it.
      await userDoc.update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      // Multi-device support: one doc per device token so a user signed in on
      // both Android and iOS receives pushes on all their devices. The token
      // itself is a valid Firestore doc id (no '/'), so use it as the key.
      await userDoc.collection('fcmTokens').doc(token).set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
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
