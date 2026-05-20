import 'package:injectable/injectable.dart';

import 'package:bloot/features/game/data/datasources/game_remote_data_source.dart';
import 'package:bloot/features/game/data/models/game_model.dart';
import 'package:bloot/features/game/domain/entities/game.dart';
import 'package:bloot/features/game/domain/repositories/game_repository.dart';

@LazySingleton(as: GameRepository)
class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl({required GameRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final GameRemoteDataSource _remoteDataSource;

  @override
  Future<Game> getGameById(String id) async {
    final model = await _remoteDataSource.getGameById(id);
    return model.toEntity();
  }
}
