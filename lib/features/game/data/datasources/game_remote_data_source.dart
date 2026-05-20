import 'package:injectable/injectable.dart';

import 'package:bloot/features/game/data/models/game_model.dart';

@lazySingleton
class GameRemoteDataSource {
  Future<GameModel> getGameById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return GameModel(
      id: id,
      players: const [
        GamePlayerModel(
          name: 'Khalid',
          avatarUrl: 'https://i.pravatar.cc/150?img=12',
          team: 'A',
          isTop: true,
        ),
        GamePlayerModel(
          name: 'Faisal',
          avatarUrl: 'https://i.pravatar.cc/150?img=33',
          team: 'B',
          isActive: true,
        ),
        GamePlayerModel(
          name: 'Omar',
          avatarUrl: 'https://i.pravatar.cc/150?img=44',
          team: 'A',
        ),
        GamePlayerModel(
          name: 'You',
          avatarUrl: 'https://i.pravatar.cc/150?img=11',
          team: 'B',
          isActive: true,
        ),
      ],
      myHand: const [
        'A♥',
        'K♠',
        'Q♦',
        'J♣',
        '10♥',
        '9♠',
        '8♦',
        '7♣',
        '6♥',
        '5♠',
        '4♦',
        '3♣',
        '2♥',
      ],
      playedCards: const ['card_0', 'card_1', 'card_2', 'card_3'],
      scoreUs: 8,
      scoreThem: 12,
      trump: 'hokm_spades',
    );
  }
}
