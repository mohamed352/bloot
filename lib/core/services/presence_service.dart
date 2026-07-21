import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';

/// Keeps the user's online presence truthful.
///
/// Three layers, in order of reliability:
/// 1. **RTDB `onDisconnect`** — the server marks `presence/{uid}` offline
///    within seconds of the connection dropping (app killed, crash, network
///    loss), even when client code never gets a chance to run.
/// 2. **App lifecycle** — backgrounding the app writes offline immediately
///    so friends don't see a stale "online" for the RTDB grace period.
/// 3. **Firestore mirror** — a Cloud Function (`syncPresence`) mirrors the
///    RTDB presence node onto `users/{uid}` (`isOnline`, `lastSeen`), which
///    is what the UI watches. The service also writes Firestore directly for
///    instant local consistency.
@lazySingleton
class PresenceService with WidgetsBindingObserver {
  PresenceService({
    required FirebaseFirestore firestore,
    required FirebaseDatabase database,
  }) : _firestore = firestore,
       _database = database;

  final FirebaseFirestore _firestore;
  final FirebaseDatabase _database;

  String? _uid;
  StreamSubscription<DatabaseEvent>? _connectedSub;
  bool _started = false;

  bool get isRunning => _started;

  /// Starts presence tracking for [uid]. Idempotent per user.
  void start(String uid) {
    if (uid.isEmpty) return;
    if (_started && _uid == uid) return;
    stop();
    _uid = uid;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _connect();
  }

  /// Stops tracking and marks the user offline (best-effort).
  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_connectedSub?.cancel());
    _connectedSub = null;
    final uid = _uid;
    _uid = null;
    if (uid != null) {
      unawaited(_writeOffline(uid));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_started || _uid == null) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _setOnline();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        unawaited(_writeOffline(_uid!));
    }
  }

  void _connect() {
    final uid = _uid;
    if (uid == null) return;
    final presenceRef = _database.ref('presence/$uid');

    unawaited(_connectedSub?.cancel());
    _connectedSub = _database.ref('.info/connected').onValue.listen((event) {
      if (event.snapshot.value != true) return;
      // Register the server-side offline marker BEFORE going online so a
      // disconnect can never leave a stale "online" behind.
      presenceRef.onDisconnect().set({
        'online': false,
        'lastSeen': ServerValue.timestamp,
      });
      _setOnline();
    });
  }

  void _setOnline() {
    final uid = _uid;
    if (uid == null || !_started) return;
    try {
      unawaited(
        _database.ref('presence/$uid').set({
          'online': true,
          'lastSeen': ServerValue.timestamp,
        }),
      );
      unawaited(
        _firestore.collection('users').doc(uid).set({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)),
      );
    } catch (e) {
      AppLogger.error('Failed to set presence online', error: e);
    }
  }

  Future<void> _writeOffline(String uid) async {
    try {
      await _database.ref('presence/$uid').set({
        'online': false,
        'lastSeen': ServerValue.timestamp,
      });
      await _firestore.collection('users').doc(uid).set({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      AppLogger.error('Failed to set presence offline', error: e);
    }
  }

  @disposeMethod
  void dispose() {
    stop();
  }
}
