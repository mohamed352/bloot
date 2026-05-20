import 'package:injectable/injectable.dart';

import 'package:bloot/features/discover/data/models/discover_stream_model.dart';

@lazySingleton
class DiscoverRemoteDataSource {
  Future<List<DiscoverStreamModel>> getStreams() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return [
      const DiscoverStreamModel(
        id: 'stream_1',
        title: 'Ahmed & Khalid vs Faisal',
        host: 'Ahmed',
        viewers: 1240,
        avatarUrl: 'https://i.pravatar.cc/150?img=11',
      ),
      const DiscoverStreamModel(
        id: 'stream_2',
        title: 'Pro League Finals',
        host: 'SaadTV',
        viewers: 856,
        avatarUrl: 'https://i.pravatar.cc/150?img=33',
        category: 'Competitive',
        isPremium: true,
      ),
      const DiscoverStreamModel(
        id: 'stream_3',
        title: 'Late Night Session',
        host: 'Khaled',
        viewers: 342,
        avatarUrl: 'https://i.pravatar.cc/150?img=44',
        category: 'Streaming',
      ),
      const DiscoverStreamModel(
        id: 'stream_4',
        title: 'Morning Baloot',
        host: 'Omar',
        viewers: 128,
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
      ),
      const DiscoverStreamModel(
        id: 'stream_5',
        title: 'Weekend Tournament',
        host: 'BlootOfficial',
        viewers: 2100,
        avatarUrl: 'https://i.pravatar.cc/150?img=22',
        category: 'Tournament',
        isPremium: true,
      ),
      const DiscoverStreamModel(
        id: 'stream_6',
        title: 'Voice Only Table',
        host: 'Faisal',
        viewers: 45,
        avatarUrl: 'https://i.pravatar.cc/150?img=33',
        category: 'Voice',
      ),
      const DiscoverStreamModel(
        id: 'stream_7',
        title: 'Casual Play',
        host: 'Nasser',
        viewers: 89,
        avatarUrl: 'https://i.pravatar.cc/150?img=44',
      ),
      const DiscoverStreamModel(
        id: 'stream_8',
        title: 'Training Room',
        host: 'CoachAli',
        viewers: 156,
        avatarUrl: 'https://i.pravatar.cc/150?img=55',
        category: 'Training',
      ),
    ];
  }

  Future<DiscoverStreamModel> getStreamById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final streams = await getStreams();
    return streams.firstWhere((s) => s.id == id);
  }

  Future<List<StreamChatMessageModel>> sendChatMessage(
    String streamId,
    String message,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return [
      const StreamChatMessageModel(user: 'Viewer1', text: 'Great play!'),
      const StreamChatMessageModel(user: 'Viewer2', text: 'Nice move Ahmed'),
      const StreamChatMessageModel(
        user: 'You',
        text: 'Hello everyone',
        isMe: true,
      ),
      const StreamChatMessageModel(user: 'Viewer3', text: 'gg'),
      StreamChatMessageModel(user: 'You', text: message, isMe: true),
    ];
  }
}
