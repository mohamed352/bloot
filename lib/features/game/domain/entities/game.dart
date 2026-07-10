/// Domain entity representing a game player.
class GamePlayer {
  const GamePlayer({
    required this.uid,
    required this.name,
    required this.avatarUrl,
    required this.team,
    required this.seatIndex,
    this.hand = const [],
    this.takenCards = const [],
    this.tricksWon = 0,
    this.bid,
    this.isActive = false,
    this.isMuted = false,
    this.hasCamera = true,
    this.isTop = false,
    this.isConnected = true,
    this.agoraUid,
    this.isSpeaking = false,
  });

  /// Returns the first letter of [name] or '?' if empty.
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';

  final String uid;
  final String name;
  final String avatarUrl;
  final String team;
  final int seatIndex;
  final List<String> hand;
  final List<String> takenCards;
  final int tricksWon;
  final String? bid;
  final bool isActive;
  final bool isMuted;
  final bool hasCamera;
  final bool isTop;
  final bool isConnected;

  /// The Agora UID derived from [uid.hashCode.abs()].
  final int? agoraUid;

  /// Whether this player is currently speaking.
  final bool isSpeaking;
}

/// Represents the current trick on the table.
class Trick {
  const Trick({
    required this.trickNumber,
    required this.trickLeaderIndex,
    this.leadingSuit,
    this.cards = const {},
    this.winnerSeat,
  });

  final int trickNumber;
  final int trickLeaderIndex;
  final String? leadingSuit;
  final Map<String, String?> cards;

  /// Seat index of the player who won this trick, set when the 4th card is played.
  final int? winnerSeat;
}

/// Domain entity representing a game session.
class Game {
  const Game({
    required this.id,
    required this.players,
    required this.myHand,
    required this.mySeatIndex,
    required this.playedCards,
    required this.scoreUs,
    required this.scoreThem,
    required this.teamAScore,
    required this.teamBScore,
    required this.trump,
    required this.status,
    required this.turnIndex,
    required this.currentRound,
    required this.targetScore,
    this.gameType,
    this.dealerIndex = 0,
    this.faceUpCard,
    this.biddingTeam,
    this.fellTeam,
    this.currentTrick,
    this.projects = const [],
    this.roomId,
    this.agoraChannelName,
    this.engineState,
  });

  final String id;
  final List<GamePlayer> players;
  final List<String> myHand;

  /// Seat index of the local (authenticated) player.
  final int mySeatIndex;
  final List<String?> playedCards;

  /// Scores from the local player's perspective.
  final int scoreUs;
  final int scoreThem;

  /// Absolute team A/B scores (server-side truth).
  final int teamAScore;
  final int teamBScore;
  final String trump;
  final String status;
  final int turnIndex;
  final int currentRound;
  final int targetScore;
  final String? gameType;
  final int dealerIndex;
  final String? faceUpCard;
  final String? biddingTeam;
  final String? fellTeam;
  final Trick? currentTrick;

  /// Detected Saudi Baloot projects (مشاريع) for the local player.
  /// Each map contains 'type' (enum name) and 'cards' (list of card keys).
  final List<Map<String, dynamic>> projects;

  final String? roomId;
  final String? agoraChannelName;
  final Map<String, dynamic>? engineState;

  /// Returns true if it's the local player's turn.
  bool get isMyTurn => turnIndex == mySeatIndex;

  /// Returns the cards the local player is allowed to play right now.
  ///
  /// When a trick is in progress, the player must follow the leading suit if
  /// possible. If they cannot follow suit, any card may be played. Returns an
  /// empty list when it is not the local player's turn.
  List<String> get legalCards {
    if (!isMyTurn || myHand.isEmpty || status != 'playing') return const [];

    final leading = currentTrick?.leadingSuit;
    if (leading == null || leading.isEmpty) return myHand;

    final follow = myHand.where((c) {
      if (c.isEmpty) return false;
      return c.substring(c.length - 1) == leading;
    }).toList();

    return follow.isNotEmpty ? follow : List<String>.from(myHand);
  }

  /// Returns the local player.
  GamePlayer get localPlayer {
    try {
      return players.firstWhere((p) => p.seatIndex == mySeatIndex);
    } catch (_) {
      return players.first;
    }
  }

  /// Returns the team letter of the local player.
  String get localTeam => localPlayer.team;

  /// Returns the player whose turn it is.
  GamePlayer? get currentPlayer {
    try {
      return players.firstWhere((p) => p.seatIndex == turnIndex);
    } catch (_) {
      return null;
    }
  }

  Game copyWith({
    String? id,
    List<GamePlayer>? players,
    List<String>? myHand,
    int? mySeatIndex,
    List<String?>? playedCards,
    int? scoreUs,
    int? scoreThem,
    int? teamAScore,
    int? teamBScore,
    String? trump,
    String? status,
    int? turnIndex,
    int? currentRound,
    int? targetScore,
    String? gameType,
    int? dealerIndex,
    String? faceUpCard,
    String? biddingTeam,
    String? fellTeam,
    Trick? currentTrick,
    List<Map<String, dynamic>>? projects,
    String? roomId,
    String? agoraChannelName,
  }) {
    return Game(
      id: id ?? this.id,
      players: players ?? this.players,
      myHand: myHand ?? this.myHand,
      mySeatIndex: mySeatIndex ?? this.mySeatIndex,
      playedCards: playedCards ?? this.playedCards,
      scoreUs: scoreUs ?? this.scoreUs,
      scoreThem: scoreThem ?? this.scoreThem,
      teamAScore: teamAScore ?? this.teamAScore,
      teamBScore: teamBScore ?? this.teamBScore,
      trump: trump ?? this.trump,
      status: status ?? this.status,
      turnIndex: turnIndex ?? this.turnIndex,
      currentRound: currentRound ?? this.currentRound,
      targetScore: targetScore ?? this.targetScore,
      gameType: gameType ?? this.gameType,
      dealerIndex: dealerIndex ?? this.dealerIndex,
      faceUpCard: faceUpCard ?? this.faceUpCard,
      biddingTeam: biddingTeam ?? this.biddingTeam,
      fellTeam: fellTeam ?? this.fellTeam,
      currentTrick: currentTrick ?? this.currentTrick,
      projects: projects ?? this.projects,
      roomId: roomId ?? this.roomId,
      agoraChannelName: agoraChannelName ?? this.agoraChannelName,
      // ignore: unnecessary_this
      engineState: engineState ?? this.engineState,
    );
  }
}
