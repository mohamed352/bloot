import 'package:bloot/features/game/domain/engine/baloot_card.dart';
import 'package:bloot/features/game/domain/engine/baloot_rules.dart';

/// Current high-level phase of a hand.
enum BalootPhase { bidding, playing, handEnd, matchEnd }

/// Describes one play inside a trick.
class TrickPlay {
  TrickPlay({required this.seat, required this.card});

  final int seat;
  final BalootCard card;
}

/// A completed trick with its winner.
class CompletedTrick {
  CompletedTrick({required this.plays, required this.winner, required this.points});

  final List<TrickPlay> plays;
  final int winner;
  final int points;
}

/// A declared or revealed project.
class ProjectClaim {
  ProjectClaim({
    required this.seat,
    required this.type,
    required this.cards,
    this.revealed = false,
  });

  final int seat;
  final ProjectType type;
  final List<BalootCard> cards;
  final bool revealed;

  int get qaid => BalootRules.projectQaidFor(BalootMode.sun)[type] ?? 0;
}

/// Bidding state machine.
class BiddingState {
  BiddingState({
    this.round = 1,
    required this.turn,
    this.spoken = 0,
    this.best,
  });

  int round;
  int turn;
  int spoken;
  BestBid? best;
}

class BestBid {
  BestBid({required this.type, required this.seat, this.suit});

  final BidActionType type;
  final int seat;
  final BalootSuit? suit;
}

/// State for a doubling auction.
class DoublingState {
  DoublingState({required this.turn, required this.stage, required this.nextLevel});

  int turn;
  String stage;
  int nextLevel;
}

/// Result of scoring a completed hand.
class HandResult {
  HandResult({
    required this.qaid,
    required this.pts,
    required this.trickWins,
    this.capotTeam,
    required this.buyerLost,
    this.safeSaved = false,
    required this.projQaid,
    required this.balootQaid,
    required this.doubleLevel,
    this.qatClaim,
  });

  final List<int> qaid;
  final List<int> pts;
  final List<int> trickWins;
  final int? capotTeam;
  final bool buyerLost;
  final bool safeSaved;
  final List<int> projQaid;
  final List<int> balootQaid;
  final int doubleLevel;
  final QatClaimResult? qatClaim;
}

class QatClaimResult {
  QatClaimResult({
    required this.type,
    required this.typeName,
    required this.failed,
    required this.claimSeat,
    this.violSeat,
    this.winTeam,
    this.violCard,
    this.trickIndex,
    this.provedBy,
  });

  final ViolationType type;
  final String typeName;
  final bool failed;
  final int claimSeat;
  final int? violSeat;
  final int? winTeam;
  final BalootCard? violCard;
  final int? trickIndex;
  final BalootCard? provedBy;
}

class ViolationRecord {
  ViolationRecord({
    required this.seat,
    required this.card,
    required this.trickIndex,
    required this.type,
    required this.escaped,
    this.confirmed = false,
    this.provedBy,
  });

  final int seat;
  final BalootCard card;
  final int trickIndex;
  final ViolationType type;
  final List<BalootCard> escaped;
  bool confirmed;
  BalootCard? provedBy;
}

/// Mutable game state for a single hand/round.
///
/// The engine operates on this state directly (mirroring the JS engine). For
/// UI immutability, callers can snapshot it via the serializer.
class BalootHandState {
  BalootHandState();

  BalootPhase phase = BalootPhase.bidding;
  List<List<BalootCard>> hands = [[], [], [], []];
  late BalootCard topCard;
  List<BalootCard> rest = [];
  late int firstPlayer;

  BalootMode? mode;
  BalootSuit? trump;
  int? buyer;
  bool ashkal = false;

  late BiddingState bidding;
  final List<TrickPlay> currentTrick = [];
  final List<CompletedTrick> trickHistory = [];
  int leader = 0;
  int turn = 0;

  final List<ProjectClaim> projects = [];
  final List<ProjectClaim> countedProjects = [];
  final List<ProjectClaim> droppedProjects = [];

  final List<ProjectClaim> pendingAnnounce = [];
  final List<ProjectClaim> pendingReveal = [];
  final List<ProjectClaim> announcedProjects = [];
  final List<ProjectClaim> revealedProjects = [];

  /// Hokm-only Baloot tracking: first K/Q of trump played by a seat.
  ({int seat, BalootRank rank, int trickIndex})? balootState;
  int? balootTeam;
  int? balootSeat;

  bool awaitingDeclare = false;
  List<int> declareSeats = [];
  Map<int, List<ProjectType>> declarations = {};

  int doubleLevel = 1;
  int? doubleTeam;
  bool awaitingDouble = false;
  DoublingState? doubling;

  ViolationRecord? violation;
  final List<ViolationRecord> pendingViolations = [];

  final List<Set<BalootSuit>> voids = [
    <BalootSuit>{},
    <BalootSuit>{},
    <BalootSuit>{},
    <BalootSuit>{},
  ];

  final List<BalootCard> playedCards = [];

  HandResult? result;

  // Helpers
  static int teamOf(int seat) => seat % 2;
}

/// Mutable match-level state.
class BalootMatch {
  BalootMatch({
    required this.players,
    this.safeMode = false,
    this.autoDeclare = false,
  });

  final List<BalootPlayerConfig> players;
  final bool safeMode;
  final bool autoDeclare;

  final List<int> totals = [0, 0];
  int dealer = 0;
  int handsPlayed = 0;
  final List<Map<String, dynamic>> handResults = [];
  BalootHandState? state;
  bool matchOver = false;
  int? winnerTeam;
}

class BalootPlayerConfig {
  const BalootPlayerConfig({required this.name, this.isBot = false, this.level = 'amateur'});

  final String name;
  final bool isBot;
  final String level;
}
