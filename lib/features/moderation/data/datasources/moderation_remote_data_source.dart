import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/moderation/domain/entities/blocked_user.dart';

@lazySingleton
class ModerationRemoteDataSource {
  ModerationRemoteDataSource({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFunctions functions,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth,
       _functions = functions;

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFunctions _functions;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  Future<void> reportUser({
    required String targetUid,
    required String targetType,
    required String reason,
    String? details,
  }) async {
    await _functions.httpsCallable('reportUser').call<void>({
      'targetUid': targetUid,
      'targetType': targetType,
      'reason': reason,
      'details': details ?? '',
    });
  }

  Future<void> blockUser(String targetUid) async {
    await _functions.httpsCallable('blockUser').call<void>({
      'targetUid': targetUid,
    });
  }

  Future<void> unblockUser(String targetUid) async {
    await _functions.httpsCallable('unblockUser').call<void>({
      'targetUid': targetUid,
    });
  }

  Future<String?> getStreamHostUid(String streamId) async {
    try {
      final doc = await _firestore.collection('streams').doc(streamId).get();
      return doc.data()?['hostUid'] as String?;
    } catch (e) {
      AppLogger.error(
        'Failed to resolve stream host',
        error: e,
        tag: 'Moderation',
      );
      return null;
    }
  }

  Stream<List<BlockedUser>> watchBlockedUsers() {
    final uid = _uid;
    if (uid == null) return Stream.value(const []);

    // Wrap the Firestore snapshot stream in a broadcast controller so we can
    // gracefully emit an empty list on permission-denied or other transient
    // errors instead of letting the error propagate and break the chat UI.
    final controller = StreamController<List<BlockedUser>>.broadcast();
    final subscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('blockedUsers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return BlockedUser(
              uid: doc.id,
              displayName: data['displayName'] as String? ?? '',
              avatarUrl: data['avatarUrl'] as String?,
            );
          }).toList(),
        )
        .listen(
          controller.add,
          onError: (Object e, StackTrace st) {
            final isPermissionDenied = e is FirebaseException &&
                e.code == 'permission-denied';
            AppLogger.warning(
              isPermissionDenied
                  ? '[Moderation] Blocked users list permission denied; returning empty list'
                  : '[Moderation] Failed to watch blocked users; returning empty list',
            );
            if (!controller.isClosed) controller.add(const []);
          },
          onDone: () async {
            if (!controller.isClosed) await controller.close();
          },
        );

    controller.onCancel = () async {
      await subscription.cancel();
      if (!controller.isClosed) await controller.close();
    };

    return controller.stream;
  }
}
