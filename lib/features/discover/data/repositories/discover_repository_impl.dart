import 'package:injectable/injectable.dart';

import 'package:bloot/features/discover/data/datasources/discover_remote_data_source.dart';
import 'package:bloot/features/discover/data/models/discover_stream_model.dart';
import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/features/discover/domain/repositories/discover_repository.dart';

@LazySingleton(as: DiscoverRepository)
class DiscoverRepositoryImpl implements DiscoverRepository {
  DiscoverRepositoryImpl({required DiscoverRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final DiscoverRemoteDataSource _remoteDataSource;

  @override
  Future<List<DiscoverStream>> getStreams() async {
    final models = await _remoteDataSource.getStreams();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<DiscoverStream>> watchStreams() {
    return _remoteDataSource.watchStreams().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<DiscoverStream> getStreamById(String id) async {
    final model = await _remoteDataSource.getStreamById(id);
    return model.toEntity();
  }

  @override
  Stream<DiscoverStream> watchStream(String id) {
    return _remoteDataSource.watchStream(id).map((model) => model.toEntity());
  }

  @override
  Stream<List<StreamChatMessage>> watchStreamChat(String streamId) {
    return _remoteDataSource
        .watchStreamChat(streamId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> sendChatMessage(String streamId, String message) async {
    return _remoteDataSource.sendChatMessage(streamId, message);
  }

  @override
  Future<String?> findStreamIdByCode(String code) {
    return _remoteDataSource.findStreamIdByCode(code);
  }

  @override
  Future<void> incrementViewerCount(String streamId) {
    return _remoteDataSource.incrementViewerCount(streamId);
  }

  @override
  Future<void> decrementViewerCount(String streamId) {
    return _remoteDataSource.decrementViewerCount(streamId);
  }

  @override
  Future<bool> isSpectatorsAllowed(String streamId) {
    return _remoteDataSource.isSpectatorsAllowed(streamId);
  }

  @override
  Future<String?> getRoomGameId(String streamId) {
    return _remoteDataSource.getRoomGameId(streamId);
  }

  @override
  Stream<String?> watchRoomGameId(String streamId) {
    return _remoteDataSource.watchRoomGameId(streamId);
  }
}
