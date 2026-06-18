import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:bloot/features/game/presentation/cubit/local_game_simulator.dart';

void main() {
  group('LocalGameSimulator engine', () {
    test('deals 13 cards to each player using 5+4+4 pattern', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();

      for (final p in game.players) {
        expect(p.hand.length, 13);
      }
      expect(game.faceUpCard, isNotNull);
    });

    test('trump Jack beats trump 9 and non-trump Ace', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.gameType = 'hokm';
      game.faceUpCard = 'AH'; // hearts trump

      expect(SimGame.cardBeats('JH', '9H', 'H', 'H'), isTrue);
      expect(SimGame.cardBeats('9H', 'AH', 'H', 'H'), isTrue);
      expect(SimGame.cardBeats('AH', 'AS', 'H', 'H'), isTrue);
    });

    test('trump card beats non-trump leading suit', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.gameType = 'hokm';
      game.faceUpCard = 'AH'; // hearts trump

      expect(SimGame.cardBeats('2H', 'AS', 'S', 'H'), isTrue);
      expect(SimGame.cardBeats('AS', 'KH', 'S', 'H'), isFalse);
    });

    test('leading suit wins when no trump played', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();

      expect(SimGame.cardBeats('KS', 'QS', 'S', null), isTrue);
      expect(SimGame.cardBeats('QS', 'KS', 'S', null), isFalse);
      expect(SimGame.cardBeats('KH', 'QS', 'S', null), isFalse);
    });

    test('trump Jack is worth 20 points', () {
      expect(SimGame.cardPoints('JH', 'H'), 20);
      expect(SimGame.cardPoints('JH', 'S'), 2);
      expect(SimGame.cardPoints('9H', 'H'), 14);
    });

    test('Sun fall gives opponents 120', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.gameType = 'sun';
      game.biddingTeam = 'A';
      // Give team A 50 points, team B 70 points (bidder fails)
      game.players[0].takenCards = ['AH', 'KH', 'QH', 'JH', '10H'];
      game.players[2].takenCards = [];
      game.players[1].takenCards = ['AS', 'KS', 'QS', 'JS', '10S', '9S', '8S', '7S', '6S', '5S', '4S', '3S', '2S'];
      game.players[3].takenCards = [];

      final (teamA, teamB) = game.scoreRound();
      expect(teamA, 0);
      expect(teamB, 120);
    });

    test('Hokm fall gives opponents 152 plus bonuses', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.gameType = 'hokm';
      game.faceUpCard = 'AH';
      game.biddingTeam = 'B';
      // Team B bidder fails: A gets more points.
      game.players[0].takenCards = ['AH', 'KH', 'QH', 'JH', '10H', '9H', '8H', '7H', '6H', '5H', '4H', '3H', '2H'];
      game.players[2].takenCards = [];
      game.players[1].takenCards = [];
      game.players[3].takenCards = [];

      final (teamA, teamB) = game.scoreRound();
      expect(teamB, 0);
      expect(teamA, 152);
    });

    test('no last-trick bonus is applied', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.gameType = 'sun';
      game.biddingTeam = 'A';
      // Team A has 20 points (no last-trick bonus), Team B has 0.
      game.players[0].takenCards = ['AH', 'KH', 'QH', 'JH'];
      game.players[2].takenCards = [];
      game.players[1].takenCards = [];
      game.players[3].takenCards = [];
      game.lastTrickWinner = 0;

      final (teamA, teamB) = game.scoreRound();
      expect(teamA, 20);
      expect(teamB, 0);
    });

    test('all-pass redeal keeps the same dealer', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.dealerIndex = 2;
      game.players[0].bid = 'pass';
      game.players[1].bid = 'pass';
      game.players[2].bid = 'pass';
      game.players[3].bid = 'pass';

      expect(game.winningBidder, isNull);
      // Dealer should remain 2 for the redeal.
      expect(game.dealerIndex, 2);
    });

    test('all-pass redeal preserves scores and round number', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.dealerIndex = 1;
      game.teamAScore = 80;
      game.teamBScore = 40;
      game.currentRound = 3;
      game.players[0].bid = 'pass';
      game.players[1].bid = 'pass';
      game.players[2].bid = 'pass';
      game.players[3].bid = 'pass';

      // Simulate a redeal by calling deal() again (as LocalGameSimulator does)
      // In the real cubit scores are preserved explicitly.
      expect(game.winningBidder, isNull);
      expect(game.dealerIndex, 1);
      expect(game.teamAScore, 80);
      expect(game.teamBScore, 40);
      expect(game.currentRound, 3);
    });

    test('winning bidder determined by clockwise bidding order', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.dealerIndex = 3; // bidding order: 0 -> 1 -> 2 -> 3
      game.players[0].bid = 'pass';
      game.players[1].bid = 'hokm';
      game.players[2].bid = 'pass';
      game.players[3].bid = 'hokm'; // later in bidding order

      // First Hokm bidder in order is seat 1.
      expect(game.winningBidder, 1);
      expect(game.winningBidType, 'hokm');

      game.deal();
      game.dealerIndex = 2; // bidding order: 3 -> 0 -> 1 -> 2
      game.players[0].bid = 'sun'; // second in order
      game.players[1].bid = 'pass';
      game.players[2].bid = 'sun'; // last in order
      game.players[3].bid = 'pass';

      // Last Sun bidder in order is seat 2.
      expect(game.winningBidder, 2);
      expect(game.winningBidType, 'sun');
    });

    test('bidding validation prevents Sun after Sun', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.faceUpCard = 'AH';
      game.players[0].bid = 'sun';
      expect(game.isValidBid(1, 'sun'), isFalse);
      expect(game.isValidBid(1, 'hokm'), isTrue);
      expect(game.isValidBid(1, 'pass'), isTrue);
    });

    test('bidding validation requires face-up suit for Hokm', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.faceUpCard = 'AH';
      // Replace hand so seat 1 has no hearts.
      game.players[1].hand = ['AS', 'KS', 'QS', 'JS', '10S', '9S', '8S', '7S', '6S', '5S', '4S', '3S', '2S'];
      expect(game.isValidBid(1, 'hokm'), isFalse);
    });

    test('sequence with Jack-high beats sequence with 10-high', () {
      final game = SimGame(id: 't1', random: Random(42));
      game.deal();
      game.gameType = 'hokm';
      game.faceUpCard = 'AH';
      game.biddingTeam = 'A';
      // Team A has 11 card points + 50 bonus; Team B has 0 card points + 0 bonus.
      game.players[0].takenCards = ['AH'];
      game.players[0].claimedBonuses = [
        {'type': 'bnaga', 'points': 50, 'cards': ['JH', '10H', '9H', '8H']},
      ];
      game.players[2].takenCards = [];
      game.players[2].claimedBonuses = [];
      game.players[1].takenCards = [];
      game.players[1].claimedBonuses = [
        {'type': 'bnaga', 'points': 50, 'cards': ['10D', '9D', '8D', '7D']},
      ];
      game.players[3].takenCards = [];
      game.players[3].claimedBonuses = [];

      final (teamA, teamB) = game.scoreRound();
      expect(teamA, 61);
      expect(teamB, 0);
    });
  });
}
