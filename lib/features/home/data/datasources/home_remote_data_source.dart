import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/home/domain/entities/home_stream.dart';

@lazySingleton
class HomeRemoteDataSource {
  HomeRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<HomeStream>> watchLiveStreams() {
    return _firestore
        .collection('streams')
        .where('status', isEqualTo: 'live')
        .orderBy('viewerCount', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return _mapDocToEntity(doc.id, data);
          }).toList();
        })
        .handleError((Object error) {
          AppLogger.error(
            'Failed to watch live streams',
            error: error,
            tag: 'Home',
          );
          return <HomeStream>[];
        });
  }

  Future<List<HomeStream>> getLiveStreams() async {
    try {
      final snapshot = await _firestore
          .collection('streams')
          .where('status', isEqualTo: 'live')
          .orderBy('viewerCount', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _mapDocToEntity(doc.id, data);
      }).toList();
    } catch (e) {
      AppLogger.error('Failed to get live streams', error: e, tag: 'Home');
      return [];
    }
  }

  HomeStream _mapDocToEntity(String id, Map<String, dynamic> data) {
    return HomeStream(
      id: id,
      title: data['title'] as String? ?? 'Untitled Stream',
      hostName: data['hostName'] as String? ?? 'Unknown',
      hostAvatar: data['hostAvatar'] as String? ?? '',
      viewerCount: (data['viewerCount'] as num?)?.toInt() ?? 0,
      type: data['type'] as String? ?? 'Baloot',
      thumbnailUrl: data['thumbnailUrl'] as String?,
      isPremium: data['isPremium'] == true,
    );
  }
}
