/// Domain entity representing a live stream on the home screen.
class HomeStream {
  const HomeStream({
    required this.id,
    required this.title,
    required this.hostName,
    required this.hostAvatar,
    required this.viewerCount,
    this.type = 'Baloot',
    this.thumbnailUrl,
    this.isPremium = false,
    this.roomId,
  });

  final String id;
  final String title;
  final String hostName;
  final String hostAvatar;
  final int viewerCount;
  final String type;
  final String? thumbnailUrl;
  final bool isPremium;
  final String? roomId;
}
