import 'package:injectable/injectable.dart';

import 'package:bloot/features/tournament/data/datasources/tournament_remote_data_source.dart';
import 'package:bloot/features/tournament/data/models/tournament_model.dart';
import 'package:bloot/features/tournament/domain/entities/tournament.dart';
import 'package:bloot/features/tournament/domain/repositories/tournament_repository.dart';

@LazySingleton(as: TournamentRepository)
class TournamentRepositoryImpl implements TournamentRepository {
  TournamentRepositoryImpl({
    required TournamentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final TournamentRemoteDataSource _remoteDataSource;

  @override
  Future<List<Tournament>> getTournaments() async {
    final models = await _remoteDataSource.getTournaments();
    return models.map((m) => m.toEntity()).toList();
  }
}
