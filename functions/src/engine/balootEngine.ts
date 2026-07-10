import { BalootCard, BalootRank, BalootSuit, BALOOT_SUITS } from './balootCard';
import { BalootDeck, dealBalootHands } from './balootDeck';
import {
  BalootMode,
  BidActionType,
  DoubleAction,
  ProjectType,
  ViolationType,
  cardPoints,
  cardStrength,
  HOKUM_CAPOT_QAID,
  HOKUM_ROUND_TOTAL,
  indexInHokumTrumpOrder,
  indexInNaturalOrder,
  NATURAL_ORDER,
  projectQaidFor,
  SUN_CAPOT_QAID,
  SUN_ROUND_TOTAL,
  TARGET_QAID,
  BALOOT_QAID,
} from './balootRules';
import {
  BalootHandState,
  BalootMatch,
  BalootPlayerConfig,
  HandResult,
  ProjectClaim,
  QatClaimResult,
  TrickPlay,
  teamOf,
} from './balootState';

export interface BidAction {
  type: BidActionType;
  suit?: BalootSuit;
}

export class BalootEngine {
  private rng: () => number;

  constructor(rng: () => number = Math.random) {
    this.rng = rng;
  }

  // ─────────────────────────────────────────────────────────────────────
  // Deck & dealing
  // ─────────────────────────────────────────────────────────────────────

  createMatch(players: BalootPlayerConfig[], options: { safeMode?: boolean; autoDeclare?: boolean } = {}): BalootMatch {
    const match = new BalootMatch({ players, safeMode: options.safeMode ?? false, autoDeclare: options.autoDeclare ?? false });
    match.dealer = Math.floor(this.rng() * 4);
    match.handsPlayed = 0;
    return match;
  }

  startHand(match: BalootMatch): BalootHandState {
    const deck = new BalootDeck(this.rng);
    const deal = dealBalootHands(deck, match.dealer);

    const state = new BalootHandState();
    state.hands = deal.hands;
    state.topCard = deal.topCard;
    state.rest = deal.rest;
    state.firstPlayer = deal.firstPlayer;
    state.phase = 'bidding';
    state.mode = undefined;
    state.trump = undefined;
    state.buyer = undefined;
    state.ashkal = false;
    state.bidding = { round: 1, turn: deal.firstPlayer, spoken: 0 };
    state.leader = deal.firstPlayer;
    state.turn = deal.firstPlayer;
    state.doubleLevel = 1;
    state.doubleTeam = undefined;
    state.awaitingDouble = false;
    state.doubling = undefined;
    state.awaitingDeclare = false;
    state.declareSeats = [];
    state.declarations = {};

    match.state = state;
    return state;
  }

  // ─────────────────────────────────────────────────────────────────────
  // Bidding
  // ─────────────────────────────────────────────────────────────────────

  applyBid(match: BalootMatch, seat: number, action: BidAction): Record<string, unknown>[] {
    const state = match.state!;
    const bidding = state.bidding;
    if (seat !== bidding.turn) throw new Error("Not this seat's turn to bid");

    const events: Record<string, unknown>[] = [];

    if (action.type === 'sun') {
      bidding.best = { type: 'sun', seat };
      events.push({ type: 'bid', seat, say: 'صن' });
      this.finalizeBid(match, events);
      return events;
    }

    if (action.type === 'ashkal') {
      if (bidding.round !== 1) throw new Error('Ashkal only allowed in first bidding round');
      const ashkalEligible = (match.dealer + 3) % 4;
      if (seat !== match.dealer && seat !== ashkalEligible) {
        throw new Error('Ashkal only allowed for dealer or player before dealer');
      }
      bidding.best = { type: 'ashkal', seat };
      events.push({ type: 'bid', seat, say: 'أشكل' });
      this.finalizeBid(match, events);
      return events;
    }

    if (action.type === 'hokum') {
      const suit = bidding.round === 1 ? state.topCard.suit : action.suit;
      if (bidding.round === 2 && suit === state.topCard.suit) {
        throw new Error('Second-round Hokm must be a different suit');
      }
      if (!bidding.best) bidding.best = { type: 'hokum', seat, suit };
      events.push({
        type: 'bid',
        seat,
        say: bidding.round === 1 ? 'حكم' : 'حكم ثاني',
      });
    } else {
      events.push({
        type: 'bid',
        seat,
        say: bidding.round === 1 ? 'بس' : 'ولا',
      });
    }

    bidding.spoken++;
    if (bidding.spoken === 4) {
      if (bidding.best) {
        this.finalizeBid(match, events);
      } else if (bidding.round === 1) {
        bidding.round = 2;
        bidding.spoken = 0;
        bidding.turn = state.firstPlayer;
        bidding.best = undefined;
        events.push({ type: 'round2' });
      } else {
        // Everyone passed — redeal with next dealer.
        match.dealer = (match.dealer + 1) % 4;
        this.startHand(match);
        events.push({ type: 'redeal' });
      }
    } else {
      bidding.turn = (bidding.turn + 1) % 4;
    }

    return events;
  }

  private finalizeBid(match: BalootMatch, events: Record<string, unknown>[]): void {
    const state = match.state!;
    const best = state.bidding.best!;

    state.buyer = best.seat;
    state.ashkal = best.type === 'ashkal';
    state.mode = state.ashkal ? 'sun' : modeFromBid(best.type);
    state.trump = best.type === 'hokum' ? best.suit : undefined;

    // Distribute the remaining 11 cards.
    const topRecipient = state.ashkal ? (state.buyer! + 2) % 4 : state.buyer!;
    let ri = 0;
    state.hands[topRecipient].push(state.rest[ri++]);
    state.hands[topRecipient].push(state.rest[ri++]);
    for (let p = 0; p < 4; p++) {
      if (p === topRecipient) continue;
      state.hands[p].push(state.rest[ri++]);
      state.hands[p].push(state.rest[ri++]);
      state.hands[p].push(state.rest[ri++]);
    }
    state.hands[topRecipient].push(state.topCard);

    // Detect projects.
    state.projects.length = 0;
    for (let p = 0; p < 4; p++) {
      for (const pr of this.findProjects(state.hands[p], state.mode!, state.trump)) {
        state.projects.push({ seat: p, type: pr.type, cards: pr.cards, revealed: false });
      }
    }

    state.phase = 'playing';
    state.leader = state.firstPlayer;
    state.turn = state.firstPlayer;

    events.push({
      type: 'bidWon',
      seat: state.buyer,
      mode: state.mode,
      trump: state.trump,
      ashkal: state.ashkal,
    });

    // Open doubling.
    state.doubleLevel = 1;
    state.doubleTeam = undefined;
    const buyerTeam = teamOf(state.buyer!);
    const oppTeam = 1 - buyerTeam;
    const sunDoubleAllowed = state.mode === 'hokum' || (match.totals[buyerTeam] > 100 && match.totals[oppTeam] <= 100);
    if (sunDoubleAllowed) {
      state.awaitingDouble = true;
      state.doubling = { turn: (state.buyer! + 1) % 4, stage: 'offer', nextLevel: 2 };
      events.push({ type: 'doubleOpen', turn: state.doubling!.turn, stage: 'offer' });
    } else {
      state.awaitingDouble = false;
      state.doubling = undefined;
    }

    // Project declaration.
    state.countedProjects.length = 0;
    state.droppedProjects.length = 0;
    const humanSeats: number[] = [];
    for (let p = 0; p < 4; p++) {
      if (!match.players[p].isBot && state.projects.some((pr) => pr.seat === p)) {
        humanSeats.push(p);
      }
    }
    if (!match.autoDeclare && humanSeats.length > 0) {
      state.awaitingDeclare = true;
      state.declareSeats = [...humanSeats];
      state.declarations = {};
      events.push({ type: 'declareProjects', seats: humanSeats });
    } else {
      this.finalizeProjects(match, {});
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Project declaration
  // ─────────────────────────────────────────────────────────────────────

  declareProject(match: BalootMatch, seat: number, claimedTypes: ProjectType[]): void {
    const state = match.state!;
    if (!state.awaitingDeclare || !state.declareSeats.includes(seat)) {
      throw new Error('Not time to declare projects');
    }
    state.declarations[seat] = [...claimedTypes];
    state.declareSeats = state.declareSeats.filter((s) => s !== seat);
    if (state.declareSeats.length === 0) {
      this.finalizeProjects(match, state.declarations);
    }
  }

  private finalizeProjects(match: BalootMatch, declarations: Record<number, ProjectType[]>): void {
    const state = match.state!;
    const kept: ProjectClaim[] = [];

    for (let p = 0; p < 4; p++) {
      const seatProjs = state.projects.filter((pr) => pr.seat === p);
      if (match.players[p].isBot || !(p in declarations)) {
        kept.push(...seatProjs);
      } else {
        const claimed = declarations[p] ?? [];
        kept.push(...seatProjs.filter((pr) => claimed.includes(pr.type)));
      }
    }

    const res = this.resolveProjects(kept, state.mode!, state.firstPlayer);
    state.countedProjects = [...res.counted];
    state.droppedProjects = [...res.dropped];

    state.awaitingDeclare = false;
    state.declareSeats = [];
    state.announcedProjects.length = 0;
    state.revealedProjects.length = 0;

    state.pendingAnnounce = kept.map((p) => ({ seat: p.seat, type: p.type, cards: p.cards, revealed: false }));
    state.pendingReveal = state.countedProjects.map((p) => ({
      seat: p.seat,
      type: p.type,
      cards: p.cards,
      revealed: true,
    }));
  }

  // ─────────────────────────────────────────────────────────────────────
  // Project detection & resolution
  // ─────────────────────────────────────────────────────────────────────

  findProjects(hand: BalootCard[], mode: BalootMode, trump?: BalootSuit | null): ProjectClaim[] {
    const projects: ProjectClaim[] = [];

    // Hokum has no projects (Baloot is handled separately during play).
    if (mode !== 'sun') return projects;

    // Four of a kind for A/K/Q/J/10.
    for (const rank of ['A', 'K', 'Q', 'J', '10'] as BalootRank[]) {
      const cards = hand.filter((c) => c.rank === rank);
      if (cards.length === 4) {
        projects.push({
          seat: 0,
          type: rank === 'A' ? 'fourAces' : 'hundred',
          cards,
          revealed: false,
        });
      }
    }

    // Sequences per suit.
    for (const suit of BALOOT_SUITS) {
      const suitCards = hand.filter((c) => c.suit === suit);
      const idxs = suitCards.map((c) => indexInNaturalOrder(c.rank)).sort((a, b) => a - b);

      const runs: number[][] = [];
      let run: number[] = [];
      for (let k = 0; k < idxs.length; k++) {
        if (run.length > 0 && idxs[k] === run[run.length - 1] + 1) {
          run.push(idxs[k]);
        } else {
          if (run.length >= 3) runs.push([...run]);
          run = [idxs[k]];
        }
      }
      if (run.length >= 3) runs.push(run);

      for (const r of runs) {
        let take: number;
        let type: ProjectType;
        if (r.length >= 5) {
          take = 5;
          type = 'hundred';
        } else if (r.length === 4) {
          take = 4;
          type = 'fifty';
        } else {
          take = 3;
          type = 'sira';
        }
        const cards = r.slice(r.length - take).map((i) => new BalootCard(suit, NATURAL_ORDER[i]));
        projects.push({ seat: 0, type, cards, revealed: false });
      }
    }

    return projects;
  }

  private resolveProjects(
    projects: ProjectClaim[],
    mode: BalootMode,
    firstPlayer: number,
  ): { counted: ProjectClaim[]; dropped: ProjectClaim[] } {
    if (projects.length === 0) return { counted: [], dropped: [] };

    const power = (p: ProjectClaim): number => {
      const q = projectQaidFor(mode)[p.type] ?? 0;
      const top = Math.max(...p.cards.map((c) => indexInNaturalOrder(c.rank)));
      const orderBonus = (4 + p.seat - firstPlayer) % 4;
      return q * 10000 + top * 100 + (3 - orderBonus);
    };

    let best = projects[0];
    for (const p of projects) {
      if (power(p) > power(best)) best = p;
    }
    const winTeam = teamOf(best.seat);
    const counted = projects.filter((p) => teamOf(p.seat) === winTeam);
    const dropped = projects.filter((p) => teamOf(p.seat) !== winTeam);
    return { counted, dropped };
  }

  // ─────────────────────────────────────────────────────────────────────
  // Doubling
  // ─────────────────────────────────────────────────────────────────────

  applyDouble(match: BalootMatch, seat: number, action: DoubleAction): Record<string, unknown>[] {
    const state = match.state!;
    if (!state.awaitingDouble || !state.doubling) throw new Error('Not time to double');
    const d = state.doubling;
    if (seat !== d.turn) throw new Error("Not this seat's turn to double");

    const events: Record<string, unknown>[] = [];
    if (action === 'double') {
      const level = d.nextLevel;
      state.doubleLevel = level;
      state.doubleTeam = teamOf(seat);
      events.push({ type: 'doubled', seat, level });

      if (level >= 4 || state.mode === 'sun') {
        state.awaitingDouble = false;
        state.doubling = undefined;
        events.push({ type: 'doublingClosed', level });
      } else {
        d.turn = teamOf(seat) === teamOf(state.buyer!) ? (state.buyer! + 1) % 4 : state.buyer!;
        d.stage = level === 2 ? 'redouble' : 'recoat';
        d.nextLevel = level + 1;
        events.push({ type: 'doubleOpen', turn: d.turn, stage: d.stage });
      }
    } else {
      state.awaitingDouble = false;
      state.doubling = undefined;
      events.push({ type: 'doublingClosed', level: state.doubleLevel });
    }
    return events;
  }

  // ─────────────────────────────────────────────────────────────────────
  // Card play
  // ─────────────────────────────────────────────────────────────────────

  legalMoves(state: BalootHandState, seat: number, strict = false): BalootCard[] {
    const hand = state.hands[seat];
    const trick = state.currentTrick;

    if (trick.length === 0) return [...hand];

    const led = trick[0].card.suit;
    const follow = hand.filter((c) => c.suit === led);

    if (state.mode === 'sun') return follow.length > 0 ? follow : [...hand];

    // Hokum
    if (follow.length > 0) {
      if (led === state.trump) {
        const bestTrump = trick
          .filter((t) => t.card.suit === state.trump)
          .map((t) => indexInHokumTrumpOrder(t.card.rank))
          .reduce((a, b) => Math.max(a, b));
        const higher = follow.filter((c) => indexInHokumTrumpOrder(c.rank) > bestTrump);
        return higher.length > 0 ? higher : follow;
      }
      return follow;
    }

    // Void in led suit
    const winIdx = this.trickWinnerIndex(trick, state);
    const winnerSeat = trick[winIdx].seat;
    if (!strict && teamOf(winnerSeat) === teamOf(seat)) return [...hand];

    const trumps = hand.filter((c) => c.suit === state.trump);
    if (trumps.length === 0) return [...hand];

    const trumpedInTrick = trick.filter((t) => t.card.suit === state.trump);
    if (trumpedInTrick.length > 0) {
      const bestTrump = trumpedInTrick
        .map((t) => indexInHokumTrumpOrder(t.card.rank))
        .reduce((a, b) => Math.max(a, b));
      const higher = trumps.filter((c) => indexInHokumTrumpOrder(c.rank) > bestTrump);
      return higher.length > 0 ? [...hand] : trumps;
    }
    return trumps;
  }

  playCard(match: BalootMatch, seat: number, card: BalootCard): Record<string, unknown>[] {
    const state = match.state!;
    if (state.phase !== 'playing' || state.turn !== seat) {
      throw new Error("Not this seat's turn");
    }

    const hand = state.hands[seat];
    const idx = hand.findIndex((c) => c.equals(card));
    if (idx === -1) throw new Error('Card not in hand');

    const strict = state.doubleLevel >= 2;
    const legal = this.legalMoves(state, seat, strict);
    const isLegal = legal.some((c) => c.equals(card));

    if (!isLegal) {
      if (match.safeMode) throw new Error('Illegal move');
      state.pendingViolations.push({
        seat,
        card,
        trickIndex: state.trickHistory.length,
        type: this.classifyViolation(hand, state.currentTrick, state, card, seat),
        escaped: [...legal],
        confirmed: false,
      });
    }

    if (state.currentTrick.length > 0) {
      const led = state.currentTrick[0].card.suit;
      if (card.suit !== led) state.voids[seat].add(led);
    }

    hand.splice(idx, 1);
    state.currentTrick.push({ seat, card });
    state.playedCards.push(card);

    const events: Record<string, unknown>[] = [
      { type: 'played', seat, card: card.key, lead: state.currentTrick.length === 1 },
    ];

    // Baloot detection in Hokm.
    if (state.mode === 'hokum' && card.suit === state.trump && (card.rank === 'K' || card.rank === 'Q')) {
      const bs = state.balootState;
      const curTrick = state.trickHistory.length;
      if (
        bs &&
        bs.seat === seat &&
        bs.rank !== card.rank &&
        curTrick === bs.trickIndex + 1 &&
        state.balootTeam == null
      ) {
        state.balootTeam = teamOf(seat);
        state.balootSeat = seat;
        state.balootState = undefined;
        events.push({ type: 'baloot', seat });
      } else {
        state.balootState = { seat, rank: card.rank, trickIndex: curTrick };
      }
    }

    // Reveal hidden violations.
    for (const pv of state.pendingViolations) {
      if (pv.confirmed || pv.seat !== seat) continue;
      if (pv.escaped.some((e) => e.equals(card))) {
        pv.confirmed = true;
        pv.provedBy = card;
        state.violation = pv;
        events.push({
          type: 'violationRevealed',
          seat: pv.seat,
          card: pv.card.key,
          trickIndex: pv.trickIndex,
          provedBy: card.key,
        });
      }
    }

    // Project announcements on first trick.
    if (state.trickHistory.length === 0 && state.pendingAnnounce.length > 0) {
      const mine = state.pendingAnnounce.filter((p) => p.seat === seat);
      if (mine.length > 0) {
        state.pendingAnnounce = state.pendingAnnounce.filter((p) => p.seat !== seat);
        state.announcedProjects.push(...mine);
        events.push({
          type: 'projectAnnounce',
          seat,
          names: mine.map((m) => PROJECT_NAMES[m.type]),
        });
      }
    }

    // Project reveals on second trick.
    if (state.trickHistory.length === 1 && state.pendingReveal.length > 0) {
      const mine = state.pendingReveal.filter((p) => p.seat === seat);
      if (mine.length > 0) {
        state.pendingReveal = state.pendingReveal.filter((p) => p.seat !== seat);
        state.revealedProjects.push(...mine);
        for (const p of mine) {
          events.push({
            type: 'projectReveal',
            seat: p.seat,
            name: PROJECT_NAMES[p.type],
            qaid: projectQaidFor('sun')[p.type],
            cards: p.cards.map((c) => c.key),
          });
        }
      }
    }

    if (state.currentTrick.length === 4) {
      const winner = this.trickWinnerIndex(state.currentTrick, state);
      const winnerSeat = state.currentTrick[winner].seat;
      const trickPts = state.currentTrick.reduce((s, t) => s + cardPoints(t.card, state.mode!, state.trump ?? null), 0);

      state.trickHistory.push({
        plays: [...state.currentTrick],
        winner: winnerSeat,
        points: trickPts,
      });

      state.currentTrick.length = 0;
      state.leader = winnerSeat;
      state.turn = winnerSeat;
      state.violation = undefined;

      events.push({ type: 'trickEnd', winner: winnerSeat, pts: trickPts });

      if (state.trickHistory.length === 8) {
        const result = this.scoreHand(state);
        match.totals[0] += result.qaid[0];
        match.totals[1] += result.qaid[1];
        match.handResults.push({
          mode: state.mode,
          trump: state.trump,
          buyer: state.buyer,
          qaid: result.qaid,
          buyerLost: result.buyerLost,
          capotTeam: result.capotTeam,
        });
        match.handsPlayed++;
        state.phase = 'handEnd';
        state.result = result;
        events.push({ type: 'handEnd', result: this.resultToJson(result) });

        this.checkMatchEnd(match, events);
      }
    } else {
      state.turn = (state.turn + 1) % 4;
    }

    return events;
  }

  trickWinnerIndex(trick: TrickPlay[], state: BalootHandState): number {
    const led = trick[0].card.suit;
    let best = 0;
    for (let i = 1; i < trick.length; i++) {
      if (cardStrength(trick[i].card, led, state.mode!, state.trump ?? null) > cardStrength(trick[best].card, led, state.mode!, state.trump ?? null)) {
        best = i;
      }
    }
    return best;
  }

  private classifyViolation(
    hand: BalootCard[],
    trick: TrickPlay[],
    state: BalootHandState,
    card: BalootCard,
    seat: number,
  ): ViolationType {
    const led = trick.length === 0 ? undefined : trick[0].card.suit;
    if (led === undefined) return 'qatee';

    const hasLed = hand.some((c) => c.suit === led);
    if (hasLed && card.suit !== led) return 'qatee';

    if (state.mode === 'hokum') {
      if (!hasLed && state.doubleLevel >= 2) {
        const winIdx = this.trickWinnerIndex(trick, state);
        const winnerSeat = trick[winIdx].seat;
        if (teamOf(winnerSeat) === teamOf(seat)) return 'rubu';
      }
      if (card.suit === state.trump) return 'makabr';
      if (!hasLed && hand.some((c) => c.suit === state.trump)) return 'madaq';
    }
    return 'qatee';
  }

  // ─────────────────────────────────────────────────────────────────────
  // Scoring
  // ─────────────────────────────────────────────────────────────────────

  scoreHand(state: BalootHandState): HandResult {
    const mode = state.mode!;
    const buyTeam = teamOf(state.buyer!);
    const pts: [number, number] = [0, 0];
    let capotTeam: number | undefined;

    const trickWins: [number, number] = [0, 0];
    for (const t of state.trickHistory) {
      trickWins[teamOf(t.winner)]++;
      for (const play of t.plays) {
        pts[teamOf(t.winner)] += cardPoints(play.card, mode, state.trump ?? null);
      }
    }
    const lastWinner = state.trickHistory[state.trickHistory.length - 1].winner;
    pts[teamOf(lastWinner)] += 10; // Ground bonus

    if (trickWins[0] === 8) capotTeam = 0;
    if (trickWins[1] === 8) capotTeam = 1;

    const projQaid: [number, number] = [0, 0];
    for (const p of state.countedProjects) {
      projQaid[teamOf(p.seat)] += projectQaidFor('sun')[p.type];
    }

    const balootQaid: [number, number] = [0, 0];
    if (state.balootTeam != null) balootQaid[state.balootTeam] = BALOOT_QAID;

    const mult = state.doubleLevel;
    const qaid: [number, number] = [0, 0];

    if (capotTeam != null) {
      const capotValue = mode === 'hokum' ? HOKUM_CAPOT_QAID : SUN_CAPOT_QAID;
      qaid[capotTeam] = (capotValue + projQaid[capotTeam]) * mult + balootQaid[capotTeam];
      qaid[1 - capotTeam] = balootQaid[1 - capotTeam];
    } else {
      const div = mode === 'hokum' ? 10 : 5;
      const baseTotal = mode === 'hokum' ? HOKUM_ROUND_TOTAL : SUN_ROUND_TOTAL;
      const nonBuy = 1 - buyTeam;
      const nonBuyQaid = Math.round(pts[nonBuy] / div);
      const buyQaid = baseTotal - nonBuyQaid;
      qaid[nonBuy] = (nonBuyQaid + projQaid[nonBuy]) * mult + balootQaid[nonBuy];
      qaid[buyTeam] = (buyQaid + projQaid[buyTeam]) * mult + balootQaid[buyTeam];
    }

    let buyerLost = false;
    if (capotTeam == null && qaid[buyTeam] <= qaid[1 - buyTeam]) buyerLost = true;
    if (capotTeam != null && capotTeam !== buyTeam) buyerLost = true;

    // Mirror the Dart engine's safeSaved branch (state.result is normally null here).
    let safeSaved = false;
    if (buyerLost && capotTeam == null && state.result?.safeSaved === true && buyTeam === 0) {
      buyerLost = false;
      safeSaved = true;
    }

    if (buyerLost && capotTeam == null) {
      const total = qaid[0] + qaid[1] - balootQaid[buyTeam];
      qaid[1 - buyTeam] = total;
      qaid[buyTeam] = balootQaid[buyTeam];
    }

    return {
      qaid,
      pts,
      trickWins,
      capotTeam: capotTeam == null ? undefined : capotTeam,
      buyerLost,
      safeSaved,
      projQaid,
      balootQaid,
      doubleLevel: mult,
    };
  }

  // ─────────────────────────────────────────────────────────────────────
  // Qaid / Sawa claims
  // ─────────────────────────────────────────────────────────────────────

  claimQaid(match: BalootMatch, claimingSeat: number, claimType?: ViolationType): Record<string, unknown>[] {
    const state = match.state!;
    if (state.phase !== 'playing') throw new Error('Not time to claim qaid');

    const claimTeam = teamOf(claimingSeat);
    const v = state.violation;
    const correct = v != null && teamOf(v.seat) !== claimTeam && (claimType == null || claimType === v.type);

    const events: Record<string, unknown>[] = [];
    if (correct) {
      this.finishClaimedHand(match, events, {
        winTeam: claimTeam,
        loseTeam: teamOf(v.seat),
        qatClaim: {
          type: v.type,
          typeName: violationName(v.type),
          failed: false,
          claimSeat: claimingSeat,
          violSeat: v.seat,
          winTeam: claimTeam,
          violCard: v.card,
          trickIndex: v.trickIndex,
          provedBy: v.provedBy,
        },
      });
    } else {
      this.finishClaimedHand(match, events, {
        winTeam: 1 - claimTeam,
        loseTeam: claimTeam,
        qatClaim: {
          type: claimType ?? 'qatee',
          typeName: violationName(claimType ?? 'qatee'),
          failed: true,
          claimSeat: claimingSeat,
          violSeat: claimingSeat,
          winTeam: 1 - claimTeam,
        },
      });
    }

    const qc = state.result!.qatClaim!;
    events.unshift({
      type: 'qatClaimed',
      seat: claimingSeat,
      violSeat: qc.violSeat,
      failed: qc.failed,
      typeName: qc.typeName,
    });
    this.checkMatchEnd(match, events);
    return events;
  }

  claimSawa(match: BalootMatch, claimingSeat: number): Record<string, unknown>[] {
    const state = match.state!;
    if (state.phase !== 'playing') throw new Error('Not time to claim sawa');
    if (state.turn !== claimingSeat || state.currentTrick.length !== 0) {
      throw new Error('Sawa can only be claimed when leading a trick');
    }
    const remainingTricks = 8 - state.trickHistory.length;
    if (remainingTricks > 4) throw new Error('Sawa is only allowed in the last 4 tricks');

    const claimTeam = teamOf(claimingSeat);
    const guaranteed = this.sawaGuaranteed(state, claimingSeat);
    const events: Record<string, unknown>[] = [];

    if (!guaranteed) {
      this.finishClaimedHand(match, events, {
        winTeam: 1 - claimTeam,
        loseTeam: claimTeam,
        qatClaim: {
          type: 'sawa',
          typeName: violationName('sawa'),
          failed: true,
          claimSeat: claimingSeat,
          violSeat: claimingSeat,
          winTeam: 1 - claimTeam,
        },
      });
      events.unshift({ type: 'sawaClaimed', seat: claimingSeat, valid: false });
      this.checkMatchEnd(match, events);
      return events;
    }

    // Valid sawa: reveal all remaining hands, then play out the remaining tricks
    // with the claiming team winning each one.
    const revealHands = state.hands.map((h) => [...h]);
    this.playOutSawaTricks(state, claimingSeat);

    const result = this.scoreHand(state);
    result.sawa = { seat: claimingSeat, valid: true, hands: revealHands };

    match.totals[0] += result.qaid[0];
    match.totals[1] += result.qaid[1];
    match.handResults.push({
      mode: state.mode,
      trump: state.trump,
      buyer: state.buyer,
      qaid: result.qaid,
      buyerLost: result.buyerLost,
      capotTeam: result.capotTeam,
      sawa: true,
    });
    match.handsPlayed++;
    state.phase = 'handEnd';
    state.result = result;
    state.violation = undefined;

    events.push({ type: 'sawaClaimed', seat: claimingSeat, valid: true, remainingTricks });
    events.push({ type: 'handEnd', result: this.resultToJson(result) });
    this.checkMatchEnd(match, events);
    return events;
  }

  private sawaGuaranteed(state: BalootHandState, claimSeat: number): boolean {
    const team = teamOf(claimSeat);
    const hands = state.hands.map((h) => [...h]);
    return this.sawaTeamWinsAll(hands, claimSeat, state, team);
  }

  private sawaTeamWinsAll(hands: BalootCard[][], leader: number, state: BalootHandState, team: number): boolean {
    if (hands.every((h) => h.length === 0)) return true;
    return this.sawaTrickOutcome(hands, leader, [], state, team);
  }

  private sawaTrickOutcome(
    hands: BalootCard[][],
    leader: number,
    trick: TrickPlay[],
    state: BalootHandState,
    team: number,
  ): boolean {
    if (trick.length === 4) {
      const tempState = { ...state, currentTrick: trick };
      const winner = this.trickWinnerIndex(trick, tempState as BalootHandState);
      if (teamOf(winner) !== team) return false;
      const nextHands = hands.map((h) => [...h]);
      return this.sawaTeamWinsAll(nextHands, winner, state, team);
    }

    let seat: number;
    if (trick.length === 0) {
      seat = leader;
    } else {
      seat = (trick[trick.length - 1].seat + 1) % 4;
    }

    // Skip seats that have no cards left in this branch.
    while (hands[seat].length === 0) {
      seat = (seat + 1) % 4;
      if (seat === leader && hands[seat].length === 0) {
        // All remaining hands empty; this should have been caught above.
        return true;
      }
    }

    const tempState = { ...state, hands, currentTrick: trick };
    const legal = this.legalMoves(tempState as BalootHandState, seat, true);
    const mine = teamOf(seat) === team;

    for (const card of legal) {
      const nextHands = hands.map((h, i) =>
        i === seat ? h.filter((c) => c.key !== card.key) : [...h],
      );
      const ok = this.sawaTrickOutcome(nextHands, leader, [...trick, { seat, card }], state, team);
      if (mine && ok) return true;
      if (!mine && !ok) return false;
    }

    return !mine;
  }

  private playOutSawaTricks(state: BalootHandState, claimSeat: number): void {
    const team = teamOf(claimSeat);
    let leader = claimSeat;

    while (state.hands.some((h) => h.length > 0)) {
      const trick: TrickPlay[] = [];
      let seat = leader;

      for (let i = 0; i < 4; i++) {
        while (state.hands[seat].length === 0) {
          seat = (seat + 1) % 4;
        }

        const tempState = { ...state, currentTrick: trick };
        const legal = this.legalMoves(tempState as BalootHandState, seat, true);
        const card = this.pickSawaCard(state.hands, seat, legal, trick, state, team);

        state.hands[seat] = state.hands[seat].filter((c) => c.key !== card.key);
        state.playedCards.push(card);
        trick.push({ seat, card });
        seat = (seat + 1) % 4;
      }

      const winner = this.trickWinnerIndex(trick, state);
      const trickPts = trick.reduce(
        (sum, p) => sum + cardPoints(p.card, state.mode!, state.trump ?? null),
        0,
      );
      state.trickHistory.push({ plays: trick, winner, points: trickPts });
      state.currentTrick.length = 0;
      state.leader = winner;
      leader = winner;
    }

    state.violation = undefined;
  }

  private pickSawaCard(
    hands: BalootCard[][],
    seat: number,
    legal: BalootCard[],
    trick: TrickPlay[],
    state: BalootHandState,
    team: number,
  ): BalootCard {
    if (teamOf(seat) !== team) {
      return legal[0];
    }

    // For the claiming team, pick the first move that keeps the sawa guaranteed.
    for (const card of legal) {
      const nextHands = hands.map((h, i) =>
        i === seat ? h.filter((c) => c.key !== card.key) : [...h],
      );
      if (this.sawaTrickOutcome(nextHands, state.leader, [...trick, { seat, card }], state, team)) {
        return card;
      }
    }

    // Fallback (should not happen if sawa was guaranteed).
    return legal[0];
  }

  private finishClaimedHand(
    match: BalootMatch,
    events: Record<string, unknown>[],
    options: { winTeam: number; loseTeam: number; qatClaim: QatClaimResult },
  ): void {
    const state = match.state!;
    const balootQaid: [number, number] = [0, 0];
    if (state.balootTeam != null) balootQaid[state.balootTeam] = BALOOT_QAID;
    const mult = state.doubleLevel;
    const qaid: [number, number] = [0, 0];
    const capotValue = state.mode === 'hokum' ? HOKUM_CAPOT_QAID : SUN_CAPOT_QAID;
    qaid[options.winTeam] = capotValue * mult + balootQaid[options.winTeam];
    qaid[options.loseTeam] = balootQaid[options.loseTeam];

    match.totals[0] += qaid[0];
    match.totals[1] += qaid[1];
    match.handResults.push({
      mode: state.mode,
      trump: state.trump,
      buyer: state.buyer,
      qaid,
      buyerLost: true,
      capotTeam: null,
      qatClaim: true,
    });
    match.handsPlayed++;

    const result: HandResult = {
      qaid,
      pts: [0, 0],
      trickWins: [0, 0],
      buyerLost: true,
      safeSaved: false,
      projQaid: [0, 0],
      balootQaid,
      doubleLevel: mult,
      qatClaim: options.qatClaim,
    };
    state.phase = 'handEnd';
    state.result = result;
    state.violation = undefined;
    events.push({ type: 'handEnd', result: this.resultToJson(result) });
  }

  // ─────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────

  private checkMatchEnd(match: BalootMatch, events: Record<string, unknown>[]): void {
    if (match.totals[0] >= TARGET_QAID || match.totals[1] >= TARGET_QAID) {
      if (match.totals[0] !== match.totals[1]) {
        match.matchOver = true;
        match.winnerTeam = match.totals[0] > match.totals[1] ? 0 : 1;
        match.state!.phase = 'matchEnd';
        events.push({ type: 'matchEnd', winnerTeam: match.winnerTeam });
      }
    }
  }

  private resultToJson(r: HandResult): Record<string, unknown> {
    return {
      qaid: r.qaid,
      pts: r.pts,
      trickWins: r.trickWins,
      capotTeam: r.capotTeam,
      buyerLost: r.buyerLost,
      safeSaved: r.safeSaved,
      projQaid: r.projQaid,
      balootQaid: r.balootQaid,
      doubleLevel: r.doubleLevel,
      qatClaim: r.qatClaim
        ? {
            type: r.qatClaim.type,
            typeName: r.qatClaim.typeName,
            failed: r.qatClaim.failed,
            claimSeat: r.qatClaim.claimSeat,
          }
        : null,
      sawa: r.sawa
        ? {
            seat: r.sawa.seat,
            valid: r.sawa.valid,
          }
        : null,
    };
  }
}

function modeFromBid(type: BidActionType): BalootMode {
  return type === 'hokum' ? 'hokum' : 'sun';
}

function violationName(type: ViolationType): string {
  switch (type) {
    case 'qatee':
      return 'قيد قاطع';
    case 'makabr':
      return 'ما كبر بحكم';
    case 'madaq':
      return 'ما دق بحكم';
    case 'sawa':
      return 'سوا خاطئ';
    case 'rubu':
      return 'ربع في الدبل';
  }
}

const PROJECT_NAMES: Record<ProjectType, string> = {
  sira: 'سرا',
  fifty: 'خمسين',
  hundred: 'مية',
  fourAces: 'أربعمئة',
};
