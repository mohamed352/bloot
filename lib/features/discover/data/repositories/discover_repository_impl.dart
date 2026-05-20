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
  Future<DiscoverStream> getStreamById(String id) async {
    final model = await _remoteDataSource.getStreamById(id);
    return model.toEntity();
  }

  @override
  Future<List<StreamChatMessage>> sendChatMessage(
    String streamId,
    String message,
  ) async {
    final models = await _remoteDataSource.sendChatMessage(streamId, message);
    return models.map((m) => m.toEntity()).toList();
  }
}
