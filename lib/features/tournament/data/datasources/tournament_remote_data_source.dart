import 'package:injectable/injectable.dart';

import 'package:bloot/features/tournament/data/models/tournament_model.dart';

@lazySingleton
class TournamentRemoteDataSource {
  Future<List<TournamentModel>> getTournaments() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const [
      TournamentModel(
        id: 'tournament_0',
        name: 'gulf_champions_cup',
        prize: '10,000',
        participants: '23/64',
        status: 'Live',
        date: 'now',
        isPremium: true,
        isJoined: true,
      ),
      TournamentModel(
        id: 'tournament_1',
        name: 'weekend_baloot_bash',
        prize: '5,000',
        participants: '12/32',
        status: 'upcoming',
        date: 'Tomorrow',
      ),
      TournamentModel(
        id: 'tournament_2',
        name: 'riyadh_open',
        prize: 'free_entry',
        participants: '45/128',
        status: 'upcoming',
        date: 'sat_6pm',
      ),
      TournamentModel(
        id: 'tournament_3',
        name: 'pro_league_s1',
        prize: '25,000',
        participants: '64/64',
        status: 'completed',
        date: 'last_week',
        isPremium: true,
        isJoined: true,
      ),
      TournamentModel(
        id: 'tournament_4',
        name: 'ramadan_tournament',
        prize: '15,000',
        participants: '30/64',
        status: 'upcoming',
        date: 'next_friday',
        isPremium: true,
      ),
    ];
  }
}
