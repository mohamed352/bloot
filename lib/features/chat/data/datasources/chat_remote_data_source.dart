import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/chat/data/models/chat_model.dart';
import 'package:bloot/features/chat/data/models/chat_user_model.dart';

@lazySingleton
class ChatRemoteDataSource {
  ChatRemoteDataSource({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  Future<List<ChatConversationModel>> getConversations() async {
    try {
      final uid = _uid;
      if (uid == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .orderBy('updatedAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map(_mapDocToModel).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch conversations', error: e);
      return [];
    }
  }

  ChatConversationModel _mapDocToModel(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final updatedAt = data['updatedAt'];

    return ChatConversationModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      lastMessage: data['lastMessage'] as String? ?? '',
      time: updatedAt is Timestamp
          ? _formatRelativeTime(updatedAt.toDate())
          : '',
      unread: (data['unread'] as num?)?.toInt() ?? 0,
      type: data['type'] as String? ?? 'direct',
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}';
  }

  /// Returns a real-time stream of messages for [conversationId].
  Stream<List<ChatMessageModel>> watchMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapMessageDoc).toList())
        .handleError((Object e) {
          AppLogger.error(
            'Failed to watch messages for $conversationId',
            error: e,
          );
        });
  }

  ChatMessageModel _mapMessageDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final createdAt = data['createdAt'];
    final senderId = data['senderId'] as String? ?? '';

    return ChatMessageModel(
      id: doc.id,
      text: data['text'] as String? ?? '',
      isMe: senderId == _uid,
      time: createdAt is Timestamp
          ? _formatMessageTime(createdAt.toDate())
          : '',
      type: data['type'] as String? ?? 'text',
      imageUrl: data['imageUrl'] as String?,
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Sends a text [message] to [conversationId] and updates the conversation
  /// metadata for the list view.
  Future<void> sendMessage(String conversationId, String message) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    // Ensure the conversation document exists before writing a message.
    // If it doesn't exist (e.g., race condition or deleted), create a minimal
    // one so Firestore security rules don't block the message write.
    final conversationRef = _firestore
        .collection('conversations')
        .doc(conversationId);
    final conversationDoc = await conversationRef.get();

    if (!conversationDoc.exists) {
      // Extract participant UIDs from the deterministic conversation ID
      // format: dm_{uid1}_{uid2} (sorted).
      final parts = conversationId.split('_');
      final participantUids = parts.length == 3
          ? [parts[1], parts[2]]
          : <String>[uid];

      await conversationRef.set({
        'participantUids': participantUids,
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
        'unread': 0,
        'type': 'direct',
      }, SetOptions(merge: true));
    }

    final messageRef = conversationRef.collection('messages').doc();

    await messageRef.set({
      'senderId': uid,
      'text': message,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [uid],
    });

    // Re-read to get participantUids (may have just been created).
    final updatedDoc = await conversationRef.get();
    final participantUids = List<String>.from(
      (updatedDoc.data()?['participantUids'] as List<dynamic>?) ?? [],
    );

    final batch = _firestore.batch();
    batch.set(conversationRef, {
      'lastMessage': message,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    for (final participantUid in participantUids) {
      final isSender = participantUid == uid;
      batch.set(
        _firestore
            .collection('users')
            .doc(participantUid)
            .collection('conversations')
            .doc(conversationId),
        {
          // Required on create by Firestore rules
          // (isParticipantInNewMetadata), harmless on update.
          'participantUids': participantUids,
          'lastMessage': message,
          'updatedAt': FieldValue.serverTimestamp(),
          'unread': isSender ? 0 : FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  /// Searches users by [query] across displayName and username using
  /// server-side prefix queries. Returns an empty list when the user is not
  /// authenticated.
  Future<List<ChatUserModel>> searchUsers(String query) async {
    try {
      final uid = _uid;
      if (uid == null) return [];

      final trimmed = query.trim();
      if (trimmed.isEmpty) return [];

      // Firestore has no "contains" query, so we combine:
      // 1) an exact keyword lookup on `searchKeywords` (lowercased tokens of
      //    displayName/username/email maintained by a Cloud Function trigger)
      //    — case-insensitive and script-agnostic (works for Arabic names);
      // 2) prefix range queries on username/displayName with a few case
      //    variants for partial matches and for users who don't have
      //    searchKeywords backfilled yet.
      final lower = trimmed.toLowerCase();
      final byId = <String, ChatUserModel>{};

      void collect(Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
        for (final d in docs) {
          if (d.id == uid || byId.containsKey(d.id)) continue;
          final data = d.data();
          byId[d.id] = ChatUserModel(
            id: d.id,
            displayName: (data['displayName'] as String? ?? '').trim(),
            username: (data['username'] as String?)?.trim(),
            avatarUrl: data['avatarUrl'] as String?,
          );
        }
      }

      try {
        final keywordSnapshot = await _firestore
            .collection('users')
            .where('searchKeywords', arrayContains: lower)
            .limit(10)
            .get();
        collect(keywordSnapshot.docs);
      } catch (e) {
        // Older users may lack searchKeywords, or the field may not be
        // indexed yet — fall through to the prefix queries.
        AppLogger.error('Keyword search failed', error: e);
      }

      final variants = <String>{
        trimmed,
        lower,
        trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase(),
      };

      for (final field in ['username', 'displayName']) {
        for (final variant in variants) {
          final snapshot = await _firestore
              .collection('users')
              .where(field, isGreaterThanOrEqualTo: variant)
              .where(field, isLessThan: '$variant\uf8ff')
              .limit(10)
              .get();
          collect(snapshot.docs);
        }
      }

      return byId.values.take(20).toList();
    } catch (e) {
      AppLogger.error('Failed to search users', error: e);
      return [];
    }
  }

  /// Creates or retrieves an existing direct conversation between the
  /// current user and [otherUserId]. Returns the conversation model.
  Future<ChatConversationModel> createDirectConversation(
    String otherUserId,
  ) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    // Deterministic conversation ID so both participants resolve to the same doc
    final ids = [uid, otherUserId]..sort();
    final conversationId = 'dm_${ids[0]}_${ids[1]}';

    final conversationRef = _firestore
        .collection('conversations')
        .doc(conversationId);
    final doc = await conversationRef.get();

    if (!doc.exists) {
      // Fetch the other user's profile for name/avatar
      final otherUserDoc = await _firestore
          .collection('users')
          .doc(otherUserId)
          .get();
      final otherData = otherUserDoc.data() ?? {};
      final otherName = otherData['displayName'] ?? 'Unknown';
      final otherAvatar = otherData['avatarUrl'];

      final currentUserDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      final currentData = currentUserDoc.data() ?? {};
      final currentName = currentData['displayName'] ?? 'Unknown';
      final currentAvatar = currentData['avatarUrl'];

      final batch = _firestore.batch();

      // Main conversation doc for messages and participant lookup
      batch.set(conversationRef, {
        'participantUids': [uid, otherUserId],
        'name': otherName,
        'avatarUrl': otherAvatar,
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
        'unread': 0,
        'type': 'direct',
      });

      // Per-user metadata for secure list queries
      batch.set(
        _firestore
            .collection('users')
            .doc(uid)
            .collection('conversations')
            .doc(conversationId),
        {
          'id': conversationId,
          'name': otherName,
          'avatarUrl': otherAvatar,
          'lastMessage': '',
          'updatedAt': FieldValue.serverTimestamp(),
          'unread': 0,
          'type': 'direct',
          'participantUids': [uid, otherUserId],
        },
      );
      batch.set(
        _firestore
            .collection('users')
            .doc(otherUserId)
            .collection('conversations')
            .doc(conversationId),
        {
          'id': conversationId,
          'name': currentName,
          'avatarUrl': currentAvatar,
          'lastMessage': '',
          'updatedAt': FieldValue.serverTimestamp(),
          'unread': 0,
          'type': 'direct',
          'participantUids': [uid, otherUserId],
        },
      );

      await batch.commit();
    }

    return _mapDocToModel(await conversationRef.get());
  }

  /// One-shot message loading from Firestore.
  /// Prefer [watchMessages] for real-time updates.
  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      return snapshot.docs.map(_mapMessageDoc).toList();
    } catch (e) {
      AppLogger.error('Failed to get messages for $conversationId', error: e);
      return [];
    }
  }
}
