import 'package:injectable/injectable.dart';

import 'package:bloot/features/tournament/data/datasources/tournament_remote_data_source.dart';
import 'package:bloot/features/tournament/data/models/tournament_model.dart';
import 'package:bloot/features/tournament/domain/entities/tournament.dart';
import 'package:bloot/features/tournament/domain/repositories/tournament_repository.dart';

@LazySingleton(as: TournamentRepository)
class TournamentRepositoryImpl implements TournamentRepository {
  TournamentRepositoryImpl({required TournamentRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final TournamentRemoteDataSource _remoteDataSource;

  @override
  Future<List<Tournament>> getTournaments() async {
    final models = await _remoteDataSource.getTournaments();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Tournament?> getTournamentById(String id) async {
    final model = await _remoteDataSource.getTournamentById(id);
    return model?.toEntity();
  }

  @override
  Stream<Tournament> watchTournament(String id) {
    return _remoteDataSource.watchTournament(id).map((model) => model.toEntity());
  }

  @override
  Future<Tournament> joinTournament(String tournamentId) async {
    final model = await _remoteDataSource.joinTournament(tournamentId);
    return model.toEntity();
  }
}
