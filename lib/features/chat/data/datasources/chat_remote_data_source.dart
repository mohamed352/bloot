import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/chat/data/models/chat_model.dart';

@lazySingleton
class ChatRemoteDataSource {
  ChatRemoteDataSource({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  Future<List<ChatConversationModel>> getConversations() async {
    try {
      final uid = _uid;
      if (uid == null) return [];

      final snapshot = await _firestore
          .collection('conversations')
          .where('participantUids', arrayContains: uid)
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
        .map(
          (snapshot) => snapshot.docs.map(_mapMessageDoc).toList(),
        )
        .handleError((Object e) {
      AppLogger.error('Failed to watch messages for $conversationId', error: e);
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

    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'senderId': uid,
      'text': message,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [uid],
    });

    // Update conversation lastMessage and updatedAt for the list view
    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': message,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Searches users by [query] across displayName and username.
  /// Returns an empty list when the user is not authenticated.
  Future<List<ChatConversationModel>> searchUsers(String query) async {
    try {
      final uid = _uid;
      if (uid == null) return [];

      final snapshot = await _firestore.collection('users').limit(50).get();

      final lowerQuery = query.toLowerCase().trim();
      return snapshot.docs
          .where((d) => d.id != uid)
          .where((d) {
            final data = d.data();
            final name =
                (data['displayName'] ?? '').toString().toLowerCase();
            final username =
                (data['username'] ?? '').toString().toLowerCase();
            return lowerQuery.isEmpty ||
                name.contains(lowerQuery) ||
                username.contains(lowerQuery);
          })
          .map((d) {
            final data = d.data();
            return ChatConversationModel(
              id: d.id,
              name: data['displayName'] as String? ?? '',
              avatarUrl: data['avatarUrl'] as String?,
              lastMessage: '',
              time: '',
              type: 'direct',
            );
          })
          .toList();
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

    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);
    final doc = await conversationRef.get();

    if (!doc.exists) {
      // Fetch the other user's profile for name/avatar
      final otherUserDoc =
          await _firestore.collection('users').doc(otherUserId).get();
      final otherData = otherUserDoc.data() ?? {};

      await conversationRef.set({
        'participantUids': [uid, otherUserId],
        'name': otherData['displayName'] ?? 'Unknown',
        'avatarUrl': otherData['avatarUrl'],
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
        'unread': 0,
        'type': 'direct',
      });
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
      AppLogger.error(
        'Failed to get messages for $conversationId',
        error: e,
      );
      return [];
    }
  }
}
