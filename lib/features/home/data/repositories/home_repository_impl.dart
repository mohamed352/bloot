import 'package:injectable/injectable.dart';

import 'package:bloot/features/home/data/datasources/home_remote_data_source.dart';
import 'package:bloot/features/home/domain/entities/home_stream.dart';
import 'package:bloot/features/home/domain/repositories/home_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required HomeRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Stream<List<HomeStream>> watchLiveStreams() =>
      _remoteDataSource.watchLiveStreams();

  @override
  Future<List<HomeStream>> getLiveStreams() =>
      _remoteDataSource.getLiveStreams();
}
