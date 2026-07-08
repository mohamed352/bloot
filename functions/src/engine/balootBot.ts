import { BalootCard, BalootSuit, BALOOT_SUITS } from './balootCard';
import { BalootEngine } from './balootEngine';
import {
  BidActionType,
  cardPoints,
  cardStrength,
  HOKUM_TRUMP_ORDER,
  NATURAL_ORDER,
  SUN_ORDER,
} from './balootRules';
import { BalootHandState, BalootMatch, teamOf } from './balootState';

export type BotLevel = 'beginner' | 'amateur' | 'skilled' | 'pro';

interface BidThresholds {
  hokum: number;
  sun: number;
  noise: number;
}

export class BalootBot {
  private rng: () => number;
  private engine: BalootEngine;

  constructor(rng: () => number = Math.random) {
    this.rng = rng;
    this.engine = new BalootEngine(rng);
  }

  decideBid(match: BalootMatch, seat: number, level: BotLevel): { type: BidActionType; suit?: BalootSuit } {
    const state = match.state!;
    const hand = state.hands[seat];
    const top = state.topCard;
    const round = state.bidding.round;
    const best = state.bidding.best;

    const thresholds = thresholdsFor(level);
    let adj = 0;
    if (round === 2) {
      adj -= 0.4;
      if (state.bidding.spoken === 3 && !best) adj -= 0.8;
    }
    const hokumThresh = thresholds.hokum + adj;
    const sunThresh = thresholds.sun + adj;

    const noise = () => (this.rng() * 2 - 1) * thresholds.noise;

    const sunScore = this.evalSun(hand, top, true) + noise();
    const canSun = !best || best.type !== 'sun';

    if (round === 1) {
      const hokumScore = this.evalHokum(hand, top.suit, top, true) + noise();
      const canHokum = !best;

      const ashkalEligible = seat === match.dealer || seat === (match.dealer + 3) % 4;
      if (ashkalEligible) {
        const ashkalScore = this.evalSun(hand, top, false) + noise();
        if (ashkalScore >= sunThresh && ashkalScore >= hokumScore && ashkalScore >= sunScore) {
          return { type: 'ashkal' };
        }
      }

      if (canSun && sunScore >= sunThresh && sunScore >= hokumScore) return { type: 'sun' };
      if (canHokum && hokumScore >= hokumThresh) return { type: 'hokum' };
      if (canSun && sunScore >= sunThresh) return { type: 'sun' };
      return { type: 'pass' };
    }

    // Round 2
    let bestSuit: BalootSuit | undefined;
    let bestScore = -1;
    for (const s of BALOOT_SUITS) {
      if (s === top.suit) continue;
      const sc = this.evalHokum(hand, s, top, true);
      if (sc > bestScore) {
        bestScore = sc;
        bestSuit = s;
      }
    }
    bestScore += noise();
    if (canSun && sunScore >= sunThresh && sunScore >= bestScore) return { type: 'sun' };
    if (!best && bestScore >= hokumThresh) return { type: 'hokum', suit: bestSuit };
    if (canSun && sunScore >= sunThresh) return { type: 'sun' };
    return { type: 'pass' };
  }

  decidePlay(match: BalootMatch, seat: number, level: BotLevel): BalootCard {
    const state = match.state!;
    const legal = this.engine.legalMoves(state, seat);
    if (legal.length === 1) return legal[0];

    if (level === 'beginner') return legal[Math.floor(this.rng() * legal.length)];

    const trick = state.currentTrick;
    const partner = (seat + 2) % 4;
    const isLast = trick.length === 3;

    // Leading the trick.
    if (trick.length === 0) {
      if (level !== 'amateur') {
        const masters = legal.filter((c) => this.isMaster(c, state));
        if (masters.length > 0) {
          return masters.reduce((a, b) =>
            cardPoints(b, state.mode!, state.trump ?? null) > cardPoints(a, state.mode!, state.trump ?? null) ? b : a
          );
        }
      }

      if (level === 'pro' && state.mode === 'hokum') {
        const trumpsOut = state.playedCards.filter((c) => c.suit === state.trump).length;
        for (const c of legal) {
          if (
            c.suit !== state.trump &&
            state.voids[partner].has(c.suit) &&
            trumpsOut < 8
          ) {
            const opp1 = (seat + 1) % 4;
            const opp2 = (seat + 3) % 4;
            if (!state.voids[opp1].has(c.suit) || !state.voids[opp2].has(c.suit)) return c;
          }
        }
      }

      if (state.mode === 'hokum' && level !== 'amateur') {
        const opp1 = (seat + 1) % 4;
        const opp2 = (seat + 3) % 4;
        const safe = legal.filter(
          (c) =>
            c.suit === state.trump ||
            (!state.voids[opp1].has(c.suit) && !state.voids[opp2].has(c.suit)),
        );
        if (safe.length > 0) return this.lowestBy(safe, state);
      }
      return this.lowestBy(legal, state);
    }

    // Inside a trick.
    const led = trick[0].card.suit;
    const winSeat = trick[this.engine.trickWinnerIndex(trick, state)].seat;
    const partnerWinning = teamOf(winSeat) === teamOf(seat);
    const curBest = trick
      .map((t) => cardStrength(t.card, led, state.mode!, state.trump ?? null))
      .reduce((a, b) => Math.max(a, b));
    const winners = legal.filter(
      (c) => cardStrength(c, led, state.mode!, state.trump ?? null) > curBest,
    );
    const pts = trick.reduce((s, t) => s + cardPoints(t.card, state.mode!, state.trump ?? null), 0);

    if (partnerWinning) {
      if (level !== 'amateur') {
        const partnerCard = trick.find((t) => t.seat === partner);
        const partnerSolid = partnerCard && (isLast || this.isMaster(partnerCard.card, state));
        if (partnerSolid) {
          const feed = legal.filter(
            (c) => cardStrength(c, led, state.mode!, state.trump ?? null) <= curBest || c.suit !== led,
          );
          if (feed.length > 0) {
            const fat = feed.reduce((a, b) =>
              cardPoints(b, state.mode!, state.trump ?? null) > cardPoints(a, state.mode!, state.trump ?? null) ? b : a
            );
            if (cardPoints(fat, state.mode!, state.trump ?? null) >= 4) return fat;
            return this.lowestBy(feed, state);
          }
        }
      }
      return this.lowestBy(legal, state);
    }

    // Opponent winning.
    if (winners.length > 0) {
      const cheapWin = winners.reduce((a, b) =>
        cardStrength(a, led, state.mode!, state.trump ?? null) < cardStrength(b, led, state.mode!, state.trump ?? null)
          ? a
          : b
      );
      if (level === 'amateur') return cheapWin;
      if (isLast) return cheapWin;
      if (pts >= 10 || cardPoints(cheapWin, state.mode!, state.trump ?? null) <= 4) return cheapWin;
      const cheap = legal.filter((c) => !winners.some((w) => w.equals(c)));
      if (cheap.length > 0 && this.rng() < 0.6) return this.lowestBy(cheap, state);
      return cheapWin;
    }

    return this.lowestBy(legal, state);
  }

  decideDouble(match: BalootMatch, seat: number, level: BotLevel): boolean {
    const score = this.handStrength(match, seat);
    const base = {
      beginner: 0.04,
      amateur: 0.1,
      skilled: 0.18,
      pro: 0.28,
    }[level];
    const isBuyTeam = teamOf(seat) === teamOf(match.state!.buyer!);
    const strongThresh = isBuyTeam ? 6.4 : 5.4;
    const chance = score >= strongThresh ? base + 0.35 : base * 0.25;
    return this.rng() < chance;
  }

  // ─────────────────────────────────────────────────────────────────────
  // Evaluation helpers
  // ─────────────────────────────────────────────────────────────────────

  private evalHokum(hand: BalootCard[], suit: BalootSuit, topCard: BalootCard, takesTop: boolean): number {
    const cards = takesTop && topCard.suit === suit ? [...hand, topCard] : [...hand];
    const trumps = cards.filter((c) => c.suit === suit);
    let score = 0;
    const trumpScores: Record<string, number> = {
      J: 3.2,
      '9': 2.2,
      A: 1.6,
      '10': 1.2,
      K: 0.8,
      Q: 0.8,
      '8': 0.8,
      '7': 0.8,
    };
    for (const c of trumps) {
      score += trumpScores[c.rank] ?? 0.8;
    }
    for (const c of cards) {
      if (c.suit === suit) continue;
      if (c.rank === 'A') score += 1.1;
      if (c.rank === '10') score += 0.5;
    }
    if (trumps.length >= 4) score += 1.0;
    return score;
  }

  private evalSun(hand: BalootCard[], topCard: BalootCard, takesTop: boolean): number {
    const cards = takesTop ? [...hand, topCard] : [...hand];
    let score = 0;
    let aces = 0;
    const sunScores: Record<string, number> = {
      A: 2.6,
      '10': 1.4,
      K: 0.7,
      Q: 0.3,
      J: 0,
      '9': 0,
      '8': 0,
      '7': 0,
    };
    for (const c of cards) {
      score += sunScores[c.rank] ?? 0;
      if (c.rank === 'A') aces++;
    }
    score += aces * 5.0;
    for (const s of BALOOT_SUITS) {
      if (cards.filter((c) => c.suit === s).length >= 3) score += 0.5;
    }
    return score;
  }

  private handStrength(match: BalootMatch, seat: number): number {
    const state = match.state!;
    return state.mode === 'hokum'
      ? this.evalHokum(state.hands[seat], state.trump!, state.topCard, false)
      : this.evalSun(state.hands[seat], state.topCard, false);
  }

  private isMaster(card: BalootCard, state: BalootHandState): boolean {
    const order = state.mode === 'hokum' && card.suit === state.trump ? HOKUM_TRUMP_ORDER : SUN_ORDER;
    const myPow = order.indexOf(card.rank);
    for (const r of NATURAL_ORDER) {
      if (order.indexOf(r) <= myPow) continue;
      const played = state.playedCards.some((c) => c.suit === card.suit && c.rank === r);
      if (!played) return false;
    }
    return true;
  }

  private lowestBy(cards: BalootCard[], state: BalootHandState): BalootCard {
    return cards.reduce((a, b) => {
      const pa = cardPoints(a, state.mode!, state.trump ?? null);
      const pb = cardPoints(b, state.mode!, state.trump ?? null);
      if (pa !== pb) return pa < pb ? a : b;
      return cardStrength(a, a.suit, state.mode!, state.trump ?? null) <
        cardStrength(b, b.suit, state.mode!, state.trump ?? null)
        ? a
        : b;
    });
  }
}

function thresholdsFor(level: BotLevel): BidThresholds {
  switch (level) {
    case 'beginner':
      return { hokum: 6.6, sun: 7.7, noise: 2.0 };
    case 'amateur':
      return { hokum: 6.1, sun: 7.3, noise: 1.0 };
    case 'skilled':
      return { hokum: 5.6, sun: 6.9, noise: 0.5 };
    case 'pro':
      return { hokum: 5.2, sun: 6.6, noise: 0.15 };
  }
}
