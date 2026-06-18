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

  @override
  Stream<Game> watchGame(String id) {
    return _remoteDataSource.watchGame(id).map((model) => model.toEntity());
  }

  @override
  Stream<Game> watchGameAsSpectator(String id) {
    return _remoteDataSource.watchGameAsSpectator(id).map((model) => model.toEntity());
  }

  @override
  Future<void> placeBid(String gameId, String bid) async {
    return _remoteDataSource.placeBid(gameId, bid);
  }

  @override
  Future<void> playCard(String gameId, String card) async {
    return _remoteDataSource.playCard(gameId, card);
  }

  @override
  Future<void> claimBonuses(String gameId, List<Map<String, dynamic>> bonuses) async {
    return _remoteDataSource.claimBonuses(gameId, bonuses);
  }

  @override
  Future<void> dealNextRound(String gameId) async {
    return _remoteDataSource.dealNextRound(gameId);
  }

  @override
  Future<void> rematch(String roomId) async {
    return _remoteDataSource.rematch(roomId);
  }
}
