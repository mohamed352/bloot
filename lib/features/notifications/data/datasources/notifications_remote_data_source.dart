import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/notifications/data/models/notification_item_model.dart';

@lazySingleton
class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _uid;
    if (uid == null) {
      throw Exception('No authenticated user');
    }
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  /// Real-time stream of all notifications, newest first.
  Stream<List<NotificationItemModel>> watchNotifications() {
    try {
      return _collection
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(_mapDocToModel).toList());
    } catch (e) {
      AppLogger.error('Failed to watch notifications', error: e);
      return Stream.value(const []);
    }
  }

  /// Real-time stream of unread notifications.
  Stream<List<NotificationItemModel>> watchUnreadNotifications() {
    try {
      return _collection
          .where('read', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(_mapDocToModel).toList());
    } catch (e) {
      AppLogger.error('Failed to watch unread notifications', error: e);
      return Stream.value(const []);
    }
  }

  Future<List<NotificationItemModel>> getNotifications() async {
    try {
      final snapshot = await _collection
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map(_mapDocToModel).toList();
    } catch (e) {
      AppLogger.error('Failed to get notifications', error: e);
      return [];
    }
  }

  Future<List<NotificationItemModel>> getUnreadNotifications() async {
    try {
      final snapshot = await _collection
          .where('read', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map(_mapDocToModel).toList();
    } catch (e) {
      AppLogger.error('Failed to get unread notifications', error: e);
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _collection.doc(notificationId).update({'read': true});
    } catch (e) {
      AppLogger.error('Failed to mark notification as read', error: e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _collection
          .where('read', isEqualTo: false)
          .limit(100)
          .get();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      AppLogger.error('Failed to mark all notifications as read', error: e);
    }
  }

  NotificationItemModel _mapDocToModel(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final createdAt = data['createdAt'];

    return NotificationItemModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'system',
      titleAr: data['titleAr'] as String?,
      bodyAr: data['bodyAr'] as String?,
      roomId: data['roomId'] as String?,
      read: data['read'] == true,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }
}
